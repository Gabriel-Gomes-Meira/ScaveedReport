require_relative 'notifier'
require_relative 'scraper'
include Notifier
include Scraper

require "mongo"


client = Mongo::Client.new([ '127.0.0.1:27017' ],
                           :database => 'mining_net_development')

user = client[:users].find({}).first

if user
  $token = user[:telegram][:token]
  $chatid = user[:telegram][:chat_id]

  db = client.database
  listens = db[:listens]
  for ele in listens.find({}) do
    begin
      page = readed_page(ele[:url])

      current_state = scrap_value(scrap_items(page, ele[:element_indentifier]),
                                    "inner_html")

      reports = db[:reports]
      unless reports.find({ "from": ele[:_id], "content": current_state }).first
        ##Relatar mudança no banco de dados
        reports.insert_one({
                              "from": ele[:_id],
                              "content": current_state
                            })

        #notificar no telegram
        model = db[:notification_models].find({"listen_id"=>ele[:_id]}).first
        notificar_telegram(mount_message(model[:wanted_items], model[:message]),
                            !model[:message].rindex("<img>").nil?)

        #executar tarefa associada
        model_task = db[:model_task].find({"listen_id"=>ele[:_id]}).first
        if !model_task.nil?
          db[:queued_tasks].insert_one(model_task.except(:_id))
        end
      end

    end
  end
end
