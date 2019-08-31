class LinebotController < ApplicationController
	require 'line/bot' # gem 'line-bot-api'
	require 'google_api_calendar_v3'
	require 'weather_forecast'
	require 'google_api_drive'
	require 'google_api_photo'
	require 'user_registration'

	# callbackアクションのCSRFトークン認証を無効
	protect_from_forgery :expect => [:callback]

	def client
		@client ||= Line::Bot::Client.new { |config|
			config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
			config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
		}
	end

	def callback
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
						google_calendar = GoogleCalendar.new
						message = {
							type: 'text', 
							text: google_calendar.get_schedule
						}
					when '天気' #天気予報
						forecast = WeatherForecast.new
						message = {
							type: 'text', 
							text: forecast.get_weather
						}
					when '新着' # Google Driveの共有ディレクトリ
						google_drive = GoogleDrive.new
						message = {
							type: 'text', 
							text: google_drive.get_new_files
						}
					when '今日のわんこ'
						google_photo = GooglePhoto.new
						image_url = google_photo.get_random_photo_url
						message = {
							type: 'image',
							originalContentUrl: image_url, 
							previewImageUrl: image_url
					}
					when '登録'
						user_registration = UserRegistration.new(event)
						result_registration_message = user_registration.regster_user
						message = {
							type: 'text', 
							text: result_registration_message
						}
					else
						message = {
							type: 'text',
							text: event.message['text']
					}
					end
					
					client.reply_message(event['replyToken'], message)
				end
			when Line::Bot::Event::MessageType::Image
				puts "Event type == #{event.type}"
				puts "Event message == #{event.message}"
				puts "Event contentProvider == #{event.message['contentProvider']}"
			end
		}
		head :ok
		
	end

end
