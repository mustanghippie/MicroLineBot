class GoogleDrive

  require 'google/apis/drive_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'redis'
  require 'logger'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'MicroLineBot'.freeze
  CLIENT_SECRETS_PATH = 'client_secrets.json'.freeze
  CREDENTIALS_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY
  #SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_FILE
  $redis = Redis.new
  $logger = Logger.new(STDERR)

  def get_drive

    # Initialize the API
    service = Google::Apis::DriveV3::DriveService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # List the 10 most recently modified files(folder:0Bx0dyeY_u_LUcmY1eHpJSWhSaG8)
    response = service.list_files(q: "'0Bx0dyeY_u_LUcmY1eHpJSWhSaG8' in parents",
                                  page_size: 10,
                                  fields: 'nextPageToken, files(id, name)')

    puts 'No files found' if response.files.empty?
    save_new_file_list(response) unless response.files.empty?
    
    #get_file_list

  end

  def authorize
    unless ENV['RAILS_ENV'] == 'production'
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      #token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
    else
      # 環境変数名がカレンダーのものになっているので、共通の名前に後で変える
      client_secrets = JSON.parse(ENV["CLIENT_ID_CALENDAR"])
      client_id =  Google::Auth::ClientId.from_hash(client_secrets)
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new(url: ENV['REDIS_URL'])) 
    end

    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'gdrive'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      unless ENV['RAILS_ENV'] == 'production'
        code = YAML.load_file('setting_drive.yaml')
        code = code['code']
      else
        code = ENV['AUTHORIZETION_CODE_GOOGLE_DRIVE']
      end
      
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  # 共有ディレクトリ内にファイルが作成or削除されたらリストアップ
  # その後redisに共有ディレクトリのファイルリストを保存  
  def save_new_file_list(response)
    new_file_list = Array.new
    response.files.each do |file|
      new_file_list << file.name
    end
    new_file_list.sort!

    old_file_list = $redis.get('file_list')
    # 初回時 or Redisのデータが消えた時用
    if old_file_list.nil? 
      old_file_list = Array.new
      $redis.set('file', old_file_list)
    else 
      old_file_list = JSON.parse(old_file_list)
    end

    # 差分
    different_file_list = new_file_list - old_file_list

    message = "今日の新着は"
    unless different_file_list.empty?
      different_file_list.each do |val| 
        #puts "File name: #{val}"
        message += "\n#{val}"
      end
      message += "\nだよ"
      $redis.set('file_list', new_file_list)
    else
      #puts "新規ファイルなし"
      message += "ないよ"
    end
    message
  end

  # Redisから現在の共有ディレクトリのファイルリスト取得 
  def get_file_list
    file_list = $redis.get('file_list')
    return "ファイルなし" if file_list.nil?
    file_list = JSON.parse(file_list)
    file_list.each do |val|
      puts "File name: #{val}"
    end
  end

end