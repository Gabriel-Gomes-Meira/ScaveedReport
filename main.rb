require "mongo"
require "httparty"
require 'nokogiri'
require 'telegram/bot'


client = Mongo::Client.new([ '127.0.0.1:27017' ],
                           :database => 'mining_net_development')

token = 'token'
bot = Telegram::Bot::Client.new(token)
bot.send_message(chat_id: chat_id, text: 'Message')

while true do
  db = client.database
  listens = db[:listens]
  for ele in listens.find({}) do
    page = HTTParty.get ele[:url]
    if page
      page = Nokogiri::HTML(page)

      locator = ele[:searched_item][:locator]
      scrap_function = page.method(locator.to_sym)
      current_state = scrap_function.call(ele[:searched_item][:indentifier])

      reports = db[:reports]
      unless reports.find({ "from": ele[:_id],
                            "content": current_state.inner_html }).first
        reports.insert_one({
                             "from": ele[:_id],
                             "content": current_state.inner_html
                           })
      end
    end
  end
  sleep(5)
end