require 'httparty'
require 'nokogiri'

module Scraper
  def readed_page(url)
    Nokogiri::HTML(HTTParty.get(url))
  end

  def scrap_items(page, locator, indentifier, recursive_path = [])

    if recursive_path.length==0
      scrap_function = page.method(locator.to_sym)
      scrap_function.call(indentifier)
    else
      item = recursive_path.shift
      scrap_items(scrap_items(page, locator, indentifier), item[:locator],
                                        item[:indentifier], recursive_path)
    end
  end

  def mount_message(model_message)

    processed_message = ""
    for i in model_message[:wanted_itens] do
      processed_message+= i[:pre_text] + scrap_items(readed_page(i[:url]), i[:locator],
                                                   i[:indentifier], i[:recursive_path])
    end

    processed_message
  end

end
