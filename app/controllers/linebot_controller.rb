class LinebotController < ApplicationController

  protect_from_forgery :except => [:callback]

  def client
    @client ||= LINE::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validaet_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_fron(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.replay_message(event['replayToken'], message)
        end
      end
    }

    head :ok
  end
end