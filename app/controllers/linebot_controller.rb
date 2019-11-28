class LinebotController < ApplicationController

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    p client
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    p events

    events.each { |event|
      p event
      case event
      when Line::Bot::Event::Message
        if event.message['text'] == "確認テンプレート"
          message = {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "Are you sure?",
                "actions": [
                    {
                      "type": "message",
                      "label": "Yes",
                      "text": "yes"
                    },
                    {
                      "type": "message",
                      "label": "No",
                      "text": "no"
                    }
                ]
            }
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] == "性別は？"
          message = {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "性別を選択して下さい。",
                "actions": [
                    {
                      "type": "message",
                      "label": "man",
                      "text": "男性"
                    },
                    {
                      "type": "message",
                      "label": "woman",
                      "text": "女性"
                    }
                ]
            }
          }
          client.reply_message(event['replyToken'], message)
        else
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: event.message['text'] + "です。"
            }
            client.reply_message(event['replyToken'], message)
          end
        end
      end
    }

    head :ok
  end
end