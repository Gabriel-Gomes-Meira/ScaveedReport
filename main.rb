require_relative 'notifier'
require_relative 'scraper'
include Notifier
include Scraper

require "mongo"


client = Mongo::Client.new([ '127.0.0.1:27017' ],
                           :database => 'mining_net_development')

while true do
  db = client.database
  listens = db[:listens]
  for ele in listens.find({}) do
    # begin
      page = readed_page(ele[:url])    
      current_state = scrap_items(page, ele[:searched_item][:locator], ele[:searched_item][:indentifier], "inner_html")
    
      test(current_state)
      reports = db[:reports]
      unless reports.find({ "from": ele[:_id],
                            "content": current_state }).first
        reports.insert_one({
                             "from": ele[:_id],
                             "content": current_state
                           })
      end
    # rescue
    #   test("deu erro...")
    # end
  end
  sleep(5)
end
