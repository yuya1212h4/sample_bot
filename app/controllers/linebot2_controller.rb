class Linebot2Controller < ApplicationController

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    @count = 0
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    p events

    events.each { |event|
      case event
      when Line::Bot::Event::Postback
        case event['postback']['data']
        when /gender/
          data = event['postback']['data']
          p data
          # gender.save
          message = {
            type: 'text',
            text: "「"+ event.message['text']+ "」を保存しました。"
          }
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::Message
        if event.message['text'] == "メニュー"
          @count += 1
          p @count
          message = {
            type: "text",
            # label: "メニュー一覧",
            text: "メニュー一覧
(1)氏名
(2)性別
(3)年齢
(4)所属
(5)学歴"
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] == "確認"
          @count += 1
          p @count
          message = {
            type: "text",
            label: "現在保存されている一覧です。",
            text: "(1)氏名\n
                    (2)性別\n
                    (3)年齢\n
                    (4)所属\n
                    (5)学歴\n"
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] == "1"
          name = event.message['text']
          p name
          # name.save
          # message = {
          #   type: 'text',
          #   text: "氏名を入力して下さい。"
          #   # text: "「"+ event.message['text']+ "」を保存しました。"
          # }

          message = {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
              "type": "text",
              "text": "氏名を入力して下さい。",
              actions: {
                "type": "postback",
                "label": "name",
                "data": "action=age&data=#{name}",
                "text": "氏名を入力して下さい"
              }
            }
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] == "2"
          message = {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "性別を選択して下さい。",
                "actions": [
                    {
                      "type": "postback",
                      "label": "男性",
                      "data":"action=gender&genderId=0",
                      "displayText": "男性",
                    },
                    {
                      "type": "postback",
                      "label": "女性",
                      "data":"action=gender&genderId=1",
                      "displayText": "女性",
                    }
                ]
            }
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'] == "3"
        elsif event.message['text'] == "4"
        elsif event.message['text'] == "5"
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