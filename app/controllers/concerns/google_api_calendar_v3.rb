class Calendar
  require 'logger'
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'googleauth/stores/redis_token_store'
  require 'fileutils'
  require 'yaml'
  require 'redis'

  Client = Google::Apis::CalendarV3
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'MicroLineBot'.freeze
  # ローカル環境でしか使わない 本番では環境変数から取得する
  CLIENT_SECRETS_PATH = 'client_secrets.json'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
  

  def get_schedule
    logger = Logger.new(STDERR)
  	# Initialize the API
  	service = Google::Apis::CalendarV3::CalendarService.new
  	service.client_options.application_name = APPLICATION_NAME
  	service.authorization = authorize

  	calendar_id = 'primary'
    today = Date.today
    tomorrow = today + 1
    
  	response = service.list_events(calendar_id,
                               max_results: 10,
                               single_events: true,
                               order_by: 'startTime',
                               time_max: tomorrow.to_time.iso8601,
                               time_min: today.to_time.iso8601)
    
  	if response.items.empty?
      scheduleList = '今日の予定はないよ'
    else
      scheduleList = "今日の予定は\n"
    end
    
  	response.items.each do |event|
      unless event.start.date_time.nil?
        scheduleList += "*#{event.summary}: #{event.start.date_time.to_time.strftime("%H:%M")} 〜 #{event.end.date_time.to_time.strftime("%H:%M")}\n"
      else
        scheduleList += "*#{event.summary}\n"
      end
      
  	end
    return scheduleList
  	
  end


  def authorize
    logger = Logger.new(STDERR)
    unless ENV['RAILS_ENV'] == 'production'
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      code = YAML.load_file('setting_calendar.yaml')
      code = code['code']
      #herokuファイルだと消えるからRedis使う
      #token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new) 
    else
      client_secrets = JSON.parse(ENV["CLIENT_SECRETS_GOOGLE_API"])
      client_id = Google::Auth::ClientId.from_hash(client_secrets)
      code = ENV['AUTHORIZETION_CODE_GOOGLE_CALENDAR']
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new(url: ENV['REDIS_URL'])) 
    end

  	authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  	user_id = 'default'
  	credentials = authorizer.get_credentials(user_id)

  	if credentials.nil?
  	  url = authorizer.get_authorization_url(base_url: OOB_URI)
  	  puts 'Open the following URL in the browser and enter the ' \
  	       'resulting code after authorization:\n' + url
  	    
  	  credentials = authorizer.get_and_store_credentials_from_code(
  	    user_id: user_id, code: code, base_url: OOB_URI
  	  )
  	end
  	credentials
  end
end