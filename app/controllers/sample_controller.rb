class SampleController < ApplicationController
  require 'logger'
  require 'google_api_calendar_v3'
  require 'redis'
  require 'weather_forecast'
  require 'google_api_drive'
  require 'google_api_photo'
  require 'picasa'

  def index
  	logger = Logger.new(STDERR)
    calendar = Calendar.new
    weatherForecast = WeatherForecast.new
    gDrive = GoogleDrive.new
    gPhoto = GooglePhoto.new
    @result = gPhoto.get_random_photo
    
    #client.album.list
    #@result = gDrive.get_drive
    #@result = calendar.get_schedule
    #@result = weatherForecast.get_weather
  end
end
