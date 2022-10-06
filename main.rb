require_relative 'notifier'
require_relative 'scraper'
include Notifier
include Scraper

require "sqlite3"
require "sequel"


client = Sequel.connect('sqlite://database/scaveed_development.db')
logs = client[:logs]
user = client[:users].first

if user
  $token = user[:telegram_token]
  $chatid = user[:telegram_chatid]

  listens = client[:listens]
  for ele in listens do
    begin
      page = readed_page(ele[:url])

      current_state = scrap_value(scrap_items(page, ele[:element_indentifier]),
                                    "inner_html")
      

      if client[:reports].where{(listen_id: ele[:id) & (current_state: current_state)} != nil

        report = {:listen_id => ele[:_id],
                :current_state => current_state,
                :at => Time.now}

        #notificar no telegram
        begin
          model = client[:notification_models].where(id: ele[:notification_model_id]).first
          if !model.nil?            
            notificar_telegram(mount_message(client[:items].where(notification_model_id: model[:id]), model[:message]),
            !model[:message].rindex("<img>").nil?)
          end
        rescue StandardError => e
          logs.insert({:message_log => e.full_message, :at => Time.new})
        rescue SyntaxError => e
          logs.insert({:message_log => e.full_message, :at => Time.new})
        end

        #executar tarefa associada
        model_task = client[:model_tasks].where(id: ele[:model_task_id]).first
        if !model_task.nil?
          client[:queued_tasks].insert(model_task.except(:id))
        end

        ##Relatar mudança no banco de dados
        client[:reports].insert(report)

      end
      
    rescue StandardError => e
      logs.insert({:message_log => e.full_message, :at => Time.new})
    rescue SyntaxError => e
      logs.insert({:message_log => e.full_message, :at => Time.new})
    end

  end
end
