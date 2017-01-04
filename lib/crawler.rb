require 'net/http'
require 'byebug'
require 'nokogiri'

module Crawler
  LOGIN_URL = 'https://logindict.youdao.com/login/acc/login'
  WORDLIST_URL = 'http://dict.youdao.com/wordbook/wordlist'

  def self.login
    uri = URI(LOGIN_URL)
    res = Net::HTTP.post_form(
      uri,
      app: 'web',
      tp: 'urstoken',
      cf: '3',
      fr: '1',
      ru: 'http://dict.youdao.com/wordbook/wordlist?keyfrom=login_from_login_from_dict2.index',
      product: 'DICT',
      type: '1',
      um: 'true',
      username: 'username',
      password: 'password')
    # cookie = res['Set-Cookie']
  end

  def self.read_word_list_page(url)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = ''
    Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
  end

  def self.page_count
    page = Nokogiri::HTML(read_word_list_page(WORDLIST_URL).body)
    page.css('#pagination a.next-page:last-child').attribute('href').value.match(/wordlist\?p=(\d+)&tags=/)[1]
  end

  def self.construct_word_list_buffer
    word_list = []
    (0..page_count.to_i).each do |page_index|
      url = "http://dict.youdao.com/wordbook/wordlist?p=#{page_index}&tags="
      page = Nokogiri::HTML(read_word_list_page(url).body)
      page.css('#wordlist .word').each do |word|
        word_list << word.attribute('title').value
      end
      puts "loading #{url}"
    end
    word_list
  end

  def self.write_to_file(word_list)
    puts 'writing to file...'
    File.open('output.txt', 'w+') do |file|
      word_list.each {|word| file.puts word}
    end
    puts 'done'
  end
end
