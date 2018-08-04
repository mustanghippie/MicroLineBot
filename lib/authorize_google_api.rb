class AuthorizeGoogleApi
  require 'google/apis/drive_v3'
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/redis_token_store'
  require 'redis'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'MicroLineBot'.freeze
  CLIENT_SECRETS_PATH = 'client_secrets.json'.freeze

  def initialize(service_name)
    case service_name
    when 'gdrive'
      @service = Google::Apis::DriveV3::DriveService.new
      @scope = Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY
    when 'gcalendar'
      @service = Google::Apis::CalendarV3::CalendarService.new
      @scope = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
    end

    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize(service_name)
  end

  def get_service
    return @service
  end

  def authorize(service_name)
    
    unless ENV['RAILS_ENV'] == 'production'
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      #token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
    else
      client_secrets = JSON.parse(ENV["CLIENT_SECRETS_GOOGLE_API"])
      client_id =  Google::Auth::ClientId.from_hash(client_secrets)
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new(url: ENV['REDIS_URL'])) 
    end

    authorizer = Google::Auth::UserAuthorizer.new(client_id, @scope, token_store)
    user_id = service_name
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      unless ENV['RAILS_ENV'] == 'production'
        code = YAML.load_file("setting_#{service_name}.yaml")
        code = code['code']
      else
        case service_name
        when 'gdrive'
          code = ENV['AUTHORIZETION_CODE_GOOGLE_DRIVE']
        when 'gcalendar'
          code = ENV['AUTHORIZETION_CODE_GOOGLE_CALENDAR']
        end
      end
      
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
    
  end

end
