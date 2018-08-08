class GoogleCalendar
  require 'authorize_google_api'
  def initialize()
    @service = AuthorizeGoogleApi.new('gcalendar').get_service
    @scheduleList = ''
  end

  def get_schedule
    make_schedule_message('今日')
    make_schedule_message('明日')
  end

  def make_schedule_message(date)
    calendar_id = 'primary'

    case date
    when '今日'
      start_date = Date.today
    when '明日'
      start_date = Date.today + 1
    else
      return
    end
    end_date = start_date + 1

    response = @service.list_events(calendar_id,
                               max_results: 10,
                               single_events: true,
                               order_by: 'startTime',
                               time_max: end_date.to_time.iso8601,
                               time_min: start_date.to_time.iso8601)
    if response.items.empty?
      @scheduleList += "#{date}の予定はないよ\n"
    else
      @scheduleList += "#{date}の予定は\n"
    end
    
    response.items.each do |event|
      unless event.start.date_time.nil?
        @scheduleList += "*#{event.summary}: #{event.start.date_time.to_time.strftime("%H:%M")} 〜 #{event.end.date_time.to_time.strftime("%H:%M")}\n"
      else
        @scheduleList += "*#{event.summary}\n"
      end
    end
    return @scheduleList
  end

end