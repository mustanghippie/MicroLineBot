class LinebotPushMessage
  require 'line/bot' # gem 'line-bot-api'
  require 'redis'

  def send_message(message_text)
    message = {
      type: 'text',
      text: message_text
    }

    unless ENV['RAILS_ENV'] == 'production'
      setting_channel = YAML.load_file("setting_line_channel.yaml")
      redis = Redis.new
      users = JSON.parse(redis.get('linebot_user_list'))
    else
      setting_channel = {channel_secret: ENV['LINE_CHANNEL_SECRET'], channel_token: ENV['LINE_CHANNEL_TOKEN']}
      redis = Redis.new(url: ENV['REDIS_URL'])
      users = JSON.parse(ENV['linebot_user_list'])
    end

    client = Line::Bot::Client.new { |config|
      config.channel_secret = setting_channel[:channel_secret]
      config.channel_token = setting_channel[:channel_token]
    }
    
    users.each{ |user|
          response = client.push_message(user, message)
    }

  end
end