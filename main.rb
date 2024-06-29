require_relative 'notifier'
require_relative 'scraper'
include Notifier
include Scraper

require "pg"
require "sequel"



client = Sequel.connect('postgres://postgres:password@db/scaveed_development')
# client = Sequel.connect('sqlite://database/scaveed_development.db')
logs = client[:logs]
user = client[:users].first


if user
  $token = user[:telegram_token]
  $chatid = user[:telegram_chatid]
  # initBrowser

  # # listens = client[:listens]
  # # for ele in listens do
  # #   begin
  # #     go_to(ele[:url])

  # #     current_state = scrap_value(scrap_items(ele[:element_indentifier]),
  # #                                   "inner_html")

  # #     # byebug
  # #     if client[:reports].where(listen_id: ele[:id], current_state: current_state).first == nil
  # #       # client.transaction do
  # #         report = {:listen_id => ele[:id],
  # #                   :current_state => current_state,
  # #                   :at => Time.now}

  # #         #notificar no telegram
  # #         begin
  # #           model = client[:notification_models].where(id: ele[:notification_model_id]).first
  # #           if !model.nil?
  # #             notificar_telegram(mount_message(client[:items].where(notification_model_id: model[:id]), model[:message]),
  # #                                !model[:message].rindex("<img>").nil?)
  # #           end
  # #         rescue StandardError => e
  # #           logs.insert({:message_log => e.full_message, :at => Time.new})
  # #         rescue SyntaxError => e
  # #           logs.insert({:message_log => e.full_message, :at => Time.new})
  # #         end

  # #         #executar tarefa associada
  # #         model_task = client[:model_tasks].where(id: ele[:model_task_id]).first
  # #         if !model_task.nil?
  # #           client[:queued_tasks].insert(model_task.except(:id, :created_at))
  # #         end

  # #         ##Relatar mudança no banco de dados
  # #         client[:reports].insert(report)
  # #       # end

  # #     end
      
  # #   rescue StandardError => e
  # #     logs.insert({:message_log => e.full_message, :at => Time.new})
  # #   rescue SyntaxError => e
  # #     logs.insert({:message_log => e.full_message, :at => Time.new})
  # #   end
  # # end

  crons = client[:crons]
  for ele in crons do
    begin

      cron_next_run = ele[:next_run]
      next_run = Time.now
      if cron_next_run                     
        next_run = Time.parse(ele[:next_run])
      end
      
      if next_run.to_i <= Time.now.to_i
        #executar tarefa associada
        model_task = client[:model_tasks].where(id: ele[:model_task_id]).first
        if !model_task.nil?
          task = model_task.except(:id, :created_at)
          task[:params] = ele[:params]
          client[:queued_tasks].insert(task)
        end
        crons.where(id: ele[:id]).update(next_run: (Time.now + ele[:interval].to_i).to_s)
      end
    rescue StandardError => e
      logs.insert({:message_log => e.full_message, :at => Time.new})
    rescue SyntaxError => e
      logs.insert({:message_log => e.full_message, :at => Time.new})
    end
  end
end
