class SampleController < ApplicationController
  require 'google_api_calendar_v3'
  require 'google_api_drive'
  require 'google_api_photo'
  require 'user_registration'

  def index
  	#logger = Logger.new(STDERR)
    #users = User.all
    #push = LinebotPushMessage.new.send_message('配信テスト')
    #tga = TestGoogleApis.new
    #puts sample
    #render 'sample/index'
    #sample.name = 'test1'
    #sample.save

    #list = sample.find([1, 2])
    #puts list
    #render 'sample/'
    #calendar = GoogleCalendar.new
    #weatherForecast = WeatherForecast.new
    #gDrive = GoogleDrive.new
    gPhoto = GooglePhoto.new
    test = {"type"=>"message", "replyToken"=>"570c60ce4afe4fb89b7484847df7a488", "source"=>{"userId"=>"U9f23546f0335cd766b54857dd77a5aae", "type"=>"user"}, "timestamp"=>1534044718794, "message"=>{"type"=>"text", "id"=>"8406128634484", "text"=>"登録"}}
    puts test['message']
    puts test['source']
    #@result = gPhoto.get_album_list
    #@result = gPhoto.get_random_photo_url
    #@result_url = gPhoto.get_random_photo_url
    #@result = calendar.get_schedule
    #gPhoto.get_images_list
    #@result_url = gPhoto.get_random_photo_url
    #@result = gPhoto.get_album_id
    #@result = gDrive.get_new_files
    #client.album.list
    #@result = gDrive.get_drive
    #@result = calendar.get_schedule
    #@result = weatherForecast.get_weather
    #user_registration = UserRegistration.new('テスト')
  end
end
