require 'telegram/bot'

module Notifier
  def bot
    token = 'token'
    Telegram::Bot::Client.new(token)
  end

  def scrap_items(url, locator, indentfier, value_type)

    ## ele.inner_html
    #  or
    ## ele.attribute
  end

  def notificar_telegram(model_message)
    ##Delimitador inicial <## , delimitador final !>

    processed_message = ""
    for i in model_message[:wanted_itens] do
      processed_message+= i[:pre_text] + scrap_items(i[:url], i[:locator],
                                                    i[:indentifier], i[:value_type])
    end

    #bot.send_message(chat_id: chat_id, text: processed_message)
  end

  def test (message)
    bot.send_message(chat_id: chat_id, text: message)
  end

end