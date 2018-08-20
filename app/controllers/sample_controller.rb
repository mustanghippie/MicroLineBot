class SampleController < ApplicationController
  require 'google_api_calendar_v3'
  require 'google_api_drive'
  require 'google_api_photo'
  require 'user_registration'
  require 'linebot_push_message'
  require 'redis'

  def index
    #logger = Logger.new(STDERR)

    # Google Calendar
    #google_calendar = GoogleCalendar.new
    #@result = google_calendar.get_schedule

    # Google Drive
    #google_drive = GoogleDrive.new
  	#@result = google_drive.get_new_files

    # Google Photo
    #google_photo = GooglePhoto.new
    #@result = google_photo.get_album_list
    #@result_url = google_photo.get_randomn_photo_url

    # LINE push message
    #linebot_push_message = LinebotPushMessage.new
    #linebot_push_message.send_message('配信テスト')
  end
end
