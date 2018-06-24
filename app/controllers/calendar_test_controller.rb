class CalendarTestController < ApplicationController
	require 'logger'
	require 'google/apis/calendar_v3'
	require 'googleauth'
	require 'googleauth/stores/file_token_store'
	require 'fileutils'
	require 'yaml'

	Client = Google::Apis::CalendarV3
	OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
	APPLICATION_NAME = 'MicroLineBot'.freeze
	CLIENT_SECRETS_PATH = 'client_secrets.json'.freeze
	CREDENTIALS_PATH = 'token.yaml'.freeze
	SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

	def index
		logger = Logger.new(STDERR)
		# Initialize the API
		service = Google::Apis::CalendarV3::CalendarService.new
		service.client_options.application_name = APPLICATION_NAME
		service.authorization = authorize

		calendar_id = 'primary'

		response = service.list_events(calendar_id,
                               max_results: 10,
                               single_events: true,
                               order_by: 'startTime',
                               time_max: Date.tomorrow.to_time.iso8601,
                               time_min: Date.today.to_time.iso8601)
		puts 'Upcoming events:'
		puts 'No upcoming events found' if response.items.empty?
		response.items.each do |event|
		  startTime = event.start.date_time || event.start.date
		  endTime = event.end.date_time || event.end.date
		  puts "- #{event.summary} (#{startTime}) - (#{endTime})"
		end

	end

	def authorize
	  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
	  
	  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
	  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
	  user_id = 'default'
	  credentials = authorizer.get_credentials(user_id)
	  code = YAML.load_file('setting.yaml');
	  if credentials.nil?
	    url = authorizer.get_authorization_url(base_url: OOB_URI)
	    puts 'Open the following URL in the browser and enter the ' \
	         'resulting code after authorization:\n' + url
	    
	    credentials = authorizer.get_and_store_credentials_from_code(
	      user_id: user_id, code: code, base_url: OOB_URI
	    )
	  end
	  credentials
	end
end
