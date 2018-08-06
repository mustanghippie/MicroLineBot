class GooglePhoto
  require 'signet/oauth_2/client'
  require 'picasa'
  require 'redis'

  def initialize
    unless ENV['RAILS_ENV'] == 'production'
      setting = YAML.load_file('setting_photo.yaml')
      user_id = setting['mail']
      @code = setting['code']
      @redis = Redis.new
      @client_secrets = ''
      File.open("client_secrets.json"){|f|
        @client_secrets = f.gets
      }
      client_secrets = JSON.parse(@client_secrets)
    else
      user_id = ENV['mail']
      @code = ENV['AUTHORIZETION_CODE_GOOGLE_PHOTO']
      @redis = Redis.new(url: ENV['REDIS_URL'])
      client_secrets = JSON.parse(ENV["CLIENT_SECRETS_GOOGLE_API"])
    end
    @client_id = client_secrets["installed"]['client_id']
    @client_secret = client_secrets["installed"]['client_secret']
    @client = Picasa::Client.new(user_id: user_id, access_token: access_token)
    @logger = Logger.new(STDERR)
  end

  def access_token
    refresh_token = @redis.get('refresh_token:gPhoto')
    if refresh_token.nil?
      signet = Signet::OAuth2::Client.new(
        code: @code,
        token_credential_uri: "https://www.googleapis.com/oauth2/v3/token",
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
      )
      signet.fetch_access_token!
      @redis.set('refresh_token:gPhoto', signet.refresh_token)
    else
      signet = Signet::OAuth2::Client.new(
        client_id: @client_id,
        client_secret: @client_secret,
        token_credential_uri: "https://www.googleapis.com/oauth2/v3/token",
        refresh_token: refresh_token
      )
      signet.refresh!
      signet.access_token
    end
  end

  def get_random_photo_url
    photo = @client.album.show('6581247637443732081').entries.sample
    photo.content.src
  end
end