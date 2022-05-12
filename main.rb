require_relative 'notifier'
include Notifier

require "mongo"
require "httparty"
require 'nokogiri'


client = Mongo::Client.new([ '127.0.0.1:27017' ],
                           :database => 'mining_net_development')

while true do
  db = client.database
  listens = db[:listens]
  for ele in listens.find({}) do
    # begin
      page = HTTParty.get ele[:url]
      page = Nokogiri::HTML(page)

      locator = ele[:searched_item][:locator]
      scrap_function = page.method(locator.to_sym)
      current_state = scrap_function.call(ele[:searched_item][:indentifier])

      test(current_state.inner_html)
      reports = db[:reports]
      unless reports.find({ "from": ele[:_id],
                            "content": current_state.inner_html }).first
        reports.insert_one({
                             "from": ele[:_id],
                             "content": current_state.inner_html
                           })
      end
    # rescue
    #   test("deu erro...")
    # end
  end
  sleep(5)
end