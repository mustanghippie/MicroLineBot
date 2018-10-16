=begin
  Livedoorが提供するお天気情報 weather hacksを使って本日と明日の天気予報を取得する。
=end
class WeatherForecast
  require 'net/http'
  require 'uri'
  require 'json'

  def get_weather
    uri = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=230010')
    json = Net::HTTP.get(uri)
    result = JSON.parse(json)
    message = ''
    # 0=>今日 1=>明日
    
    (0..1).each{|num|
      # 今日と明日
      date = result['forecasts'][num]['dateLabel']
      # 晴れや曇時々晴等の情報
      telop = result['forecasts'][num]['telop']
      # 最低気温
      unless result['forecasts'][num]['temperature']['min'].nil?
        temperature_min = '最低気温は' + result['forecasts'][num]['temperature']['min']['celsius'] + "℃\n"
      else
        temperature_min = ''
      end
      # 最高気温
      unless result['forecasts'][num]['temperature']['max'].nil?
        temperature_max = '最高気温は' + result['forecasts'][num]['temperature']['max']['celsius'] + "℃\n"
      else
        temperature_max = ''
      end

      message += "#{date}の天気は#{telop}だよ。\n#{temperature_min}#{temperature_max}"
    }
    
    # 天気予報サイトへのリンクを追加 
    message += "\n詳しくはリンク先を見てね\n" + result['pinpointLocations'][20]['link']
    # 天気予報情報
    message
  end
end