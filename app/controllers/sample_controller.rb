class SampleController < ApplicationController
  require 'logger'
  require 'google_api_calendar_v3'
  require 'redis'

  def index
  	logger = Logger.new(STDERR)
    calendar = Calendar.new
    
    @sck = calendar.get_schedule
  end
end
