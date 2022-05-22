require 'httparty'
require 'nokogiri'
require 'byebug'

module Scraper
  def readed_page(url)
    Nokogiri::HTML(HTTParty.get(url))
  end

  def scrap_items(page, indentifier, recursive_path = [], distinguer = {})

    if recursive_path.length==0
      element = page.search(indentifier)
      if distinguer[:is_last]
        element.last
      else
        element.first
      end
    else
      item = recursive_path.shift
      # byebug
      scrap_items(scrap_items(page, item), indentifier,
                      recursive_path, distinguer)
    end
  end

  def scrap_value(item, wanted_value)
    ## com scrap value eu deveria conseguir buscar tanto um attributo existente,
    ## quanto o conteúdo do elemento.
    # begin
      #byebug
      if !!item[wanted_value.to_sym]
        item[wanted_value.to_sym]
      else
        item.method(wanted_value.to_sym).call
      end

    # end
  end

  def replace_word(word, subword, otherword)
    index = word.rindex(subword)
    if index
      word[index, subword.length] = otherword
    end
  end


  def mount_message(wanted_items, message)
    # puts wanted_items[0]

    processed_message = message
    for i in wanted_items do

      item =scrap_items(readed_page(i[:url]), i[:indentifier],
                        i[:recursive_path], i[:distinguer])
      replace_word(processed_message, i[:var_name], scrap_value(item, i[:wanted_value]))
    end

    processed_message
  end

end
