require 'selenium-webdriver'
require 'byebug'

module Scraper

  # def initBrowser()
  #   options = Selenium::WebDriver::Firefox::Options.new(binary: '/usr/local/bin/firefox')
  #   options.add_argument('--headless')
  #   @@browser = Selenium::WebDriver.for :firefox, options: options
  # end

  # def go_to(url)    
  #   @@browser.get(url)
  # end

  # def scrap_items(path, islast = false )
  #     byebug

  #     element = @@browser.search(path)
  #     if islast
  #       element.last
  #     else
  #       element.first
  #     end
  # end

  # def scrap_value(item, wanted_value)
  #   ## com scrap value eu deveria conseguir buscar tanto um attributo existente,
  #   ## quanto o conteúdo do elemento.
  #   # begin
  #     #byebug
  #     if !!item[wanted_value.to_sym]
  #       item[wanted_value.to_sym]
  #     else
  #       item.method(wanted_value.to_sym).call
  #     end

  #   # end
  # end

  # def replace_word(word, subword, otherword)
  #   index = word.rindex(subword)
  #   if index
  #     word[index, subword.length] = otherword
  #   end
  # end


  # def mount_message(wanted_items, message)
  #   # puts wanted_items[0]

  #   processed_message = message
  #   for i in wanted_items do

  #     item = scrap_items(go_to(i[:url]), i[:path], i[:islast])
  #     replace_word(processed_message, i[:var_name], scrap_value(item, i[:wanted_value]))
  #   end

  #   processed_message
  # end

end
