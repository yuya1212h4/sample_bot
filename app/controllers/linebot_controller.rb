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
      case event
      when Line::Bot::Event::Postback
        case event['postback']['data']
        when /datetemp/
        # p event.postback これはnoMethoderror
        p event['postback']
        date = event['postback']['params']['datetime']
        message = {
          type: "text",
          text: date
        }
        client.reply_message(event['replyToken'], message)
        when /cancel/
          message = {
            type: "text",
            text: "後で日付を選択して下さい。"
          }
          client.reply_message(event['replyToken'], message)
        when /gender/
          message = {
            type: "text",
            text: "次にあなたの年齢を教えて下さい。"
          }
          client.reply_message(event['replyToken'], message)
        # when /age/
        #   message = {
        #     type: "text",
        #     text: "次にあなたの所属名を教えて下さい。"
        #   }
        #   client.reply_message(event['replyToken'], message)
        end
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
                    # {
                    #   "type": "message",
                    #   "label": "男性",
                    #   "text": "男性",
                    #   "data":"action=gender", type="message"では使えない
                    # },
                    # {
                    #   "type": "message",
                    #   "label": "女性",
                    #   "text": "女性",
                    #   "data":"action=gender",
                    # }
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
        elsif event.message['text'] == "カルーセル"
          message = {
            "type": "template",
            "altText": "this is a carousel template",
            "template": {
                "type": "carousel",
                "columns": [
                    {
                      # "thumbnailImageUrl": "https://example.com/bot/images/item1.jpg",
                      "imageBackgroundColor": "#FFFFFF",
                      "title": "this is menu",
                      "text": "description",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "http://example.com/page/123"
                      },
                      "actions": [
                          {
                              "type": "postback",
                              "label": "Buy",
                              "data": "action=buy&itemid=111"
                          },
                          {
                              "type": "postback",
                              "label": "Add to cart",
                              "data": "action=add&itemid=111"
                          },
                          {
                              "type": "uri",
                              "label": "View detail",
                               "uri": "http://example.com/page/111"
                          }
                      ]
                    },
                    {
                      # "thumbnailImageUrl": "https://example.com/bot/images/item2.jpg",
                      "imageBackgroundColor": "#000000",
                      "title": "this is menu",
                      "text": "description",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "http://example.com/page/222"
                      },
                      "actions": [
                          {
                              "type": "postback",
                              "label": "Buy",
                              "data": "action=buy&itemid=222"
                          },
                          {
                              "type": "postback",
                              "label": "Add to cart",
                              "data": "action=add&itemid=222"
                          },
                          {
                              "type": "uri",
                              "label": "View detail",
                              "uri": "http://example.com/page/222"
                          }
                      ]
                    }
                ],
                "imageAspectRatio": "rectangle",
                "imageSize": "cover"
            }
          }
          client.reply_message(event['replyToken'], message)
        elsif event.message['text'].match(/\d\d/)
          message = {
            type: "text",
            label: "所属",
            text: "次にあなたの所属名を教えて下さい。"
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