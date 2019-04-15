class SampleController < ApplicationController
  require 'google_api_calendar_v3'
  require 'google_api_drive'
  require 'google_api_photo'
  require 'user_registration'
  require 'linebot_push_message'
  require 'redis'
  require 'google/apis/drive_v3'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'

  def index
    @result = 'sample'
    #config.logger = Logger.new('log/development.log')
=begin
    @OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    @service = Google::Apis::DriveV3::DriveService.new
    @scope = Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY
    @redis = Redis.new(host: ENV["REDIS_HOST"])

    client_secrets = JSON.parse(ENV["CLIENT_SECRETS_GOOGLE_API"])
    
    client_id =  Google::Auth::ClientId.from_hash(client_secrets)
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: @redis)
    
    authorizer = Google::Auth::UserAuthorizer.new(client_id, @scope, token_store)
    
    user_id = 'google_drive'
    credentials = authorizer.get_credentials(user_id)
    
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: @OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      code = ENV["AUTHORIZETION_CODE_#{user_id.upcase}"]
      
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: @OOB_URI
      )
    end
=end

    # Google Calendar
    #google_calendar = GoogleCalendar.new
    #@result = google_calendar.get_schedule

    # Google Drive
    #google_drive = GoogleDrive.new
  	#@result = google_drive.get_new_files

    # Google Photo
    #google_photo = GooglePhoto.new
    #@result = google_photo.get_album_list
    #@result_url = google_photo.get_random_photo_url

    # LINE push message
    #linebot_push_message = LinebotPushMessage.new
    #linebot_push_message.send_message('配信テスト')

    # weather
    #weather_forecast = WeatherForecast.new
    #@result = weather_forecast.get_weather

    # redis
    #redis = Redis.new(host: ENV['REDIS_HOST'])
    #redis.set("test3", "hogehoge")
  end
end
