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
      report = db[:reports].find({"fromId": ele[:_id]}).first
      if report.nil?
        report = {:fromId => ele[:_id],
                   :fromName => ele[:name],
                   :registers => []}
        resp = db[:reports].insert_one(report)
        report = db[:reports].find("_id" => resp.inserted_id)
      end
      
      if report[:registers].index {|x| x[:content] == current_state} == nil

        #notificar no telegram
        begin
          model = db[:notification_models].find({"listen_id"=>ele[:_id]}).first
          if !model.nil?
            notificar_telegram(mount_message(model[:wanted_items], model[:message]),
            !model[:message].rindex("<img>").nil?)
          end
        rescue StandardError => e
          `touch notifier.log`
          `echo "#{e.full_message}" >> notifier.log`
        end

        #executar tarefa associada
        model_task = db[:model_task].find({"listen_id"=>ele[:_id]}).first
        if !model_task.nil?
          db[:queued_tasks].insert_one(model_task.except(:_id))
        end

        ##Relatar mudança no banco de dados
        report[:registers].push({:content => current_state,
                                 :created_at => Time.new})

      end
      
    rescue StandardError => e
      `touch main.log`
      `echo "#{e.full_message}" >> main.log`
    end
  end
end
