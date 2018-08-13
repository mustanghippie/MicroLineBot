class GoogleDrive
  require 'redis'
  require 'authorize_google_api' 

  def initialize()
    # GoogleDrive Oauth auzhorize
    @service = AuthorizeGoogleApi.new('google_drive').get_service
    @redis = Redis.new(url: ENV['REDIS_URL'])
  end

  def get_new_files
    response = @service.list_files(q: "'#{ENV['SHARE_FOLDER_ID']}' in parents",
                                  page_size: 10,
                                  fields: 'nextPageToken, files(id, name)')
    save_new_file_list(response) unless response.files.empty?
  end

  # 共有ディレクトリ内にファイルが作成or削除されたらリストアップ
  # その後redisに共有ディレクトリのファイルリストを保存  
  def save_new_file_list(response)
    new_file_list = Array.new
    response.files.each do |file|
      new_file_list << file.name
    end
    new_file_list.sort!

    old_file_list = @redis.get('file_list')
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
      @redis.set('file_list', new_file_list)
    else
      #puts "新規ファイルなし"
      message += "ないよ"
    end
    message
  end

  # Redisから現在の共有ディレクトリのファイルリスト取得 
  def get_file_list
    file_list = @redis.get('file_list')
    return "ファイルなし" if file_list.nil?
    file_list = JSON.parse(file_list)
    file_list.each do |val|
      puts "File name: #{val}"
    end
  end

end