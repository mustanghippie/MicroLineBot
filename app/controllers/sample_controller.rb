class SampleController < ApplicationController
  require 'logger'
  require 'google_api_calendar_v3'
  require 'redis'
  require 'weather_forecast'

  def index
  	logger = Logger.new(STDERR)
    calendar = Calendar.new
    weatherForecast = WeatherForecast.new
    #@result = calendar.get_schedule
    @result = weatherForecast.get_weather
  end
end
