require 'httparty'
require 'nokogiri'

module Scraper
  def readed_page(url)
    Nokogiri::HTML(HTTParty.get(url))
  end

  def scrap_items(page, indentifier, recursive_path, distinguer = {})

    if recursive_path.length==0
      element = page.search(indentifier)
      if distinguer[:is_last] then element.last  end
    else
      item = recursive_path.shift
      scrap_items(scrap_items(page, item[:indentifier], []), indentifier,
                      recursive_path, distinguer)
    end
  end

  def scrap_value(item, wanted_value)
    ## com scrap value eu deveria conseguir buscar tanto um attributo existente,
    ## quanto o conteúdo do elemento.
    begin
      item[wanted_value.to_sym]
    rescue
      item.method(wanted_value.to_sym).call
    end
  end

  def mount_message(wanted_items)
    # puts wanted_items[0]
    processed_message = ""
    for i in wanted_items do

      item =scrap_items(readed_page(i[:url]), i[:indentifier],
                        i[:recursive_path], i[:distinguer])
      processed_message = i[:pre_text] + scrap_value(item, i[:wanted_value])
    end

    processed_message
  end

end
