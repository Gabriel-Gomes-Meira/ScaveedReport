require 'telegram/bot'

module Notifier
  def bot
    token = 'token'
    Telegram::Bot::Client.new(token)
  end

  def notificar_telegram(message)
    bot.send_message(chat_id: chat_id, text: message)
  end

  def test (message)
    bot.send_message(chat_id: chat_id, text: message)
  end

end