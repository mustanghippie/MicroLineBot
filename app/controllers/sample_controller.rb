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
    #calendar = GoogleCalendar.new
    #weatherForecast = WeatherForecast.new
    #gDrive = GoogleDrive.new
    #gPhoto = GooglePhoto.new
    #@result = calendar.get_schedule

    #@result_url = gPhoto.get_random_photo_url
    #@result = gDrive.get_new_files
    #client.album.list
    #@result = gDrive.get_drive
    #@result = calendar.get_schedule
    #@result = weatherForecast.get_weather
  end


end
