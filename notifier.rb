require 'telegram/bot'
require 'byebug'

module Notifier
  def bot
    token = 'token'
    Telegram::Bot::Client.new(token)
  end

  def notificar_telegram(message, has_image=false)
    if !has_image
      bot.send_message(chat_id: chat_id, text: message, parse_mode: "html")
    else
      index_start =  message.rindex("<img>")
      index_end = message.rindex("</img>")

      img_tag = message.slice!(index_start..index_end+5)
      img_tag.slice!("<img>")
      img_tag.slice!("</img>")
      if img_tag.start_with?("//")
        img_tag.slice!(0..1)
      end

      byebug
      bot.send_photo(chat_id: chat_id, photo:img_tag,
                     caption:message, parse_mode:"html")
    end

  end

  def test (message)
    bot.send_message(chat_id: chat_id, text: message)
  end

end