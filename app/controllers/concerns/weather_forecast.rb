=begin
  Livedoorが提供するお天気情報 weather hacksを使って本日の天気予報を取得する。
=end
class WeatherForecast
  require 'net/http'
  require 'uri'
  require 'json'

  def get_weather
    uri = URI.parse('http://weather.livedoor.com/forecast/webservice/json/v1?city=230010')
    json = Net::HTTP.get(uri)
    result = JSON.parse(json)

    # 今日か明日
    date = result['forecasts'][0]['dateLabel']
    # 晴れや曇時々晴等の情報
    telop = result['forecasts'][0]['telop']
    # 最低気温
    unless result['forecasts'][0]['temperature']['min'].nil?
       temperature_min = '最低気温は' + result['forecasts'][0]['temperature']['min']['celsius'] + '℃です。'
    else
      temperature_min = ''
    end
    # 最高気温
    unless result['forecasts'][0]['temperature']['max'].nil?
      temperature_max = '最高気温は' + result['forecasts'][0]['temperature']['max']['celsius'] + '℃です。'
    else
      temperature_max = ''
    end
    # 天気予報サイトへのリンク  
    forecast_link = result['pinpointLocations'][20]['link']
    # 天気予報情報
    message = "#{date}の天気は#{telop}です。\n#{temperature_min}\n#{temperature_max}\n詳しくはこちら：#{forecast_link}"
  end
end