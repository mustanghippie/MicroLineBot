class CalendarPublic
  require 'logger'

  def initialize
    @logger = Logger.new(STDERR)
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.key = ''
  end

  def get_schedule
    events = @service.list_events('@gmail.com',
      time_min: Date.today.to_time.iso8601,
      time_max: Date.tomorrow.to_time.iso8601,)
    puts "Calendar name: #{events.summary}"
  end
end