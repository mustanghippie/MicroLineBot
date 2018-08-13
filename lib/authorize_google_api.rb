class AuthorizeGoogleApi
  require 'google/apis/drive_v3'
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'
  require 'redis'
  require 'net/http'
  require 'uri'
  require 'json'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'MicroLineBot'.freeze

  def initialize(service_name)
      @redis = Redis.new(url: ENV['REDIS_URL'])

    case service_name
    when 'google_drive'
      @service = Google::Apis::DriveV3::DriveService.new
      @scope = Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY
    when 'google_calendar'
      @service = Google::Apis::CalendarV3::CalendarService.new
      @scope = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
    when 'google_photo'
      @scope = "https://www.googleapis.com/auth/photoslibrary"
      credentials = authorize('google_photo')
      access_token = update_access_token_by_refresh_token(service_name, credentials)
      @service = access_token
      return
    end

    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize(service_name)
  end

  def get_service
    return @service
  end

  def authorize(service_name)
      client_secrets = JSON.parse(ENV["CLIENT_SECRETS_GOOGLE_API"])
      client_id =  Google::Auth::ClientId.from_hash(client_secrets)
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: @redis)

    authorizer = Google::Auth::UserAuthorizer.new(client_id, @scope, token_store)
    user_id = service_name
    credentials = authorizer.get_credentials(user_id)
    
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      code = ENV["AUTHORIZETION_CODE_#{service_name.upcase}"]
      
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  # Access_tokenが期限切れの場合、refresh_tokenを使ってredisのaccess_tokenを更新
  # 今のところ用途はgoogle photos apiのみ
  # DriveとCalendarはV3クラスがこの機能を実装している
  # 有効なaccess_tokenを返す
  def update_access_token_by_refresh_token(service_name, credentials)
    # access_tokenが有効かチェック
    uri = URI.parse("https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=#{credentials.access_token}")
    response = Net::HTTP.get_response(uri)
    response = JSON.parse(response.body)
    expiration_time = response['exp'].to_i
    current_time = Time.now.to_i
    
    if current_time <= expiration_time
      credentials.access_token
    else
      # access_token更新してredisへ格納
      uri = URI.parse("https://www.googleapis.com/oauth2/v4/token")
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(
        "client_id" => credentials.client_id,
        "client_secret" => credentials.client_secret,
        "grant_type" => "refresh_token",
        "refresh_token" => credentials.refresh_token,
      )

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      new_access_token = JSON.parse(response.body)['access_token']

      token_info = JSON.parse(@redis.get("g-user-token:#{service_name}"))
      token_info['access_token'] = new_access_token
      token_info['expiration_time_millis'] = current_time*1000
      token_info = token_info.to_json
      @redis.set("g-user-token:#{service_name}", token_info)

      new_access_token
    end
  end
end
