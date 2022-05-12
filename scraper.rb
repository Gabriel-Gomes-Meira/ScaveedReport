require 'httparty'
require 'nokogiri'

module Scraper
  def readed_page(url)
    Nokogiri::HTML(HTTParty.get(url))
  end

  def scrap_items(page, locator, indentfier, value_type)
    ## recursive_path
    
    
    
    ## ele.inner_html
    #  or
    ## ele.attribute    
    scrap_function = page.method(locator.to_sym)
    scrap_function.call(indentifier)[:value_type]
    
  end

  def mount_message(model_message)

    processed_message = ""
    for i in model_message[:wanted_itens] do
      processed_message+= i[:pre_text] + scrap_items(readed_page(i[:url]), i[:locator],
                                                     i[:indentifier], i[:value_type])
    end

    processed_message
  end
end
