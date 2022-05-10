require 'telegram/bot'
token = 'token'
bot = Telegram::Bot::Client.new(token)

module Notifier

  def scrap_items(locator, indentfier, value_type)

    ## ele.inner_html
    #  or
    ## ele.attribute
  end

  def notificar_telegram(model_message)
    ##Delimitador inicial <## , delimitador final !>
    juncao = []
    for i in model_message[:wanted_itens] do
      juncao.insert i[:position], scrap_items(i[:locator], i[:indentifier], i[:value_type])
      juncao.insert i[:position]-1
    end

    #processed_message = juncao.join()
    #bot.send_message(chat_id: chat_id, text: processed_message)
  end

end