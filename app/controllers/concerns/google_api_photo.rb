class GooglePhoto
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'redis'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'MicroLineBot'.freeze
  CLIENT_SECRETS_PATH = 'client_secrets.json'.freeze
  SCOPE = 'https://picasaweb.google.com/data/'.freeze

  def initialize
    #@client = nil
    @logger = Logger.new(STDERR)
    unless ENV['RAILS_ENV'] == 'production'
      @redis = Redis.new
      @setting = YAML.load_file('setting_photo.yaml') 
    else
      @redis = Redis.new(url: ENV['REDIS_URL'])
    end
  end

  def get_random_photo
    authorize()
    user_token = JSON.parse(@redis.get('g-user-token:gPhoto'))
    
    unless ENV['RAILS_ENV'] == 'production'
      user_id = @setting['mail']
    else
      user_id = ENV['mail']
    end
    access_token = user_token['access_token']

    client = Picasa::Client.new(
      user_id: user_id,
      access_token: access_token
    )
    # ランダムでフォルダから画像を取得
    #album = client.album.list.entries.find{ |a| a.title == 'Dog'}
    photo = client.album.show('6581247637443732081').entries.sample
    photo.content.src

  end

  def authorize
    unless ENV['RAILS_ENV'] == 'production'
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    else
      client_secrets = JSON.parse(ENV["CLIENT_SECRETS_GOOGLE_API"])
      client_id =  Google::Auth::ClientId.from_hash(client_secrets)
    end
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: @redis) 
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'gPhoto'

    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      unless ENV['RAILS_ENV'] == 'production'
        code = @setting['code']
      else
        code = ENV['AUTHORIZETION_CODE_GOOGLE_PHOTO']
      end
      
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

end