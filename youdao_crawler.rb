require './lib/crawler'

word_list = Crawler.construct_word_list_buffer
Crawler.write_to_file(word_list)
