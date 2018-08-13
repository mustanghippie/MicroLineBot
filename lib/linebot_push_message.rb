class LinebotPushMessage
  require 'line/bot' # gem 'line-bot-api'

  def send_message(message_text)
    message = {
      type: 'text',
      text: message_text
    }
    
    setting_channel = {channel_secret: ENV['LINE_CHANNEL_SECRET'], channel_token: ENV['LINE_CHANNEL_TOKEN']}
    users = User.select(:uid)

    client = Line::Bot::Client.new { |config|
      config.channel_secret = setting_channel[:channel_secret]
      config.channel_token = setting_channel[:channel_token]
    }
    
    users.each{ |user|
          response = client.push_message(user.uid, message)
    }

  end
end