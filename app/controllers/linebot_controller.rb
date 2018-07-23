class LinebotController < ApplicationController
	require 'logger'
	require 'line/bot' # gem 'line-bot-api'
	require 'google_api_calendar_v3'
	require 'weather_forecast'
	require 'google_api_drive'
	require 'google_api_photo'

	# callbackアクションのCSRFトークン認証を無効
	protect_from_forgery :expect => [:callback]

	def client
		@client ||= Line::Bot::Client.new { |config|
			config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
			config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
		}
	end

	def callback
		calendar = Calendar.new
		forecast = WeatherForecast.new
		google_drive = GoogleDrive.new
		google_photo = GooglePhoto.new
		body = request.body.read

		signature = request.env['HTTP_X_LINE_SIGNATURE']
		unless client.validate_signature(body, signature)
			#error 400 do 'Bad request' end
			#例外処理にした方が良い気がする
			redirect_to controller: :sample, action: :error_screen
			exit
		end

		events = client.parse_events_from(body)

		events.each { |event|
			case event
			when Line::Bot::Event::Message
				case event.type
				when Line::Bot::Event::MessageType::Text
					case event.message['text']
					when '予定' #GoogleCalendar
						message = {
							type: 'text', 
							text: calendar.get_schedule
						}
					when '天気' #天気予報
						message = {
							type: 'text', 
							text: forecast.get_weather
						}
					when '新着' # Google Driveの共有ディレクトリ
						message = {
							type: 'text', 
							text: google_drive.get_drive
						}
					when '犬'
						image_url = google_photo.get_random_photo_url
						message = {
							type: 'image',
							originalContentUrl: image_url, 
							previewImageUrl: image_url
					}
					else
						message = {
							type: 'text',
							text: event.message['text']
					}
					end
					
					client.reply_message(event['replyToken'], message)
				end
			end
		}
		head :ok
		
	end

end
