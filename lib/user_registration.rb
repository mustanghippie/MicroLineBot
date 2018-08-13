class UserRegistration
  require 'net/http'
  require 'uri'
  
  def initialize(event)
    return if event.nil?
    @event = event
  end

  def get_user_id
    @event['source']['userId']
  end

  def get_user_name
    line_channel_token = ENV['LINE_CHANNEL_TOKEN']

    uri = URI.parse("https://api.line.me/v2/bot/profile/U9f23546f0335cd766b54857dd77a5aae")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{line_channel_token}"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)['displayName']
  end

  def regster_user
    line_user_id = get_user_id
    line_user_name = get_user_name
    begin
      User.create(
        name: line_user_name,
        uid: line_user_id
      )
    rescue ActiveRecord::RecordNotUnique => error
      # 登録済み
      return '既に登録済みです'
    end
    '登録しました。'
  end

end