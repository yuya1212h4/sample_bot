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
                      "label": "男性",
                      "text": "man"
                    },
                    {
                      "type": "message",
                      "label": "女性",
                      "text": "woman"
                    }
                ]
            }
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] == "日付選択"
          message = {
            "type": "template",
            "altText": "this is a buttons template",
            "template": {
                "type": "buttons",
                "title": "日程選択",
                "text": "日程を選択して下さい。",
                "actions": [
                    {
                      "type":"datetimepicker",
                      "label":"Select date",
                      "data":"action=datetemp&selectId=1",
                      "mode":"datetime",
                      "initial":"2017-12-25t00:00",
                      "max":"2018-01-24t23:59",
                      "min":"2017-12-25t00:00"
                    },
                    {
                      "type": "postback",
                      "label": "今は選択しない",
                      "data": "action=cancel&selectId=2"
                    },
                ]
            }
          }
          p message
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