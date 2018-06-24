class LinebotController < ApplicationController
	require 'logger'
	require 'line/bot' # gem 'line-bot-api'

	# error_log
	logger = Logger.new(STDERR)

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
		logger.debug("パス-----");

		events = client.parse_events_from(body)
		logger.debug("イベント --- "+events)
		events.each { |event|
			case event
			when Line::Bot::Event::Message
				case event.type
				when Line::Bot::Event::MessageType::Text
					message = {
						type: 'text',
						text: event.message['text']
					}
					client.reply_message(event['replyToken'], message)
				end
			end
		}
		head :ok
		
	end

end
