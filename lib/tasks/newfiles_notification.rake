namespace :newfiles_notification do
  require 'google_api_drive'
  require 'linebot_push_message'
  desc "共有ドライブの新規ファイルを通知するタスク"
  task notice_files: :environment do
    gDrive = GoogleDrive.new
    result = gDrive.get_new_files
    unless result.eql?('今日の新着はないよ') 
      LinebotPushMessage.new.send_message(result)
    end
  end
end
