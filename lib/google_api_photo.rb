class GooglePhoto
  require 'authorize_google_api'
  require 'net/http'
  require 'uri'

  def initialize
    @access_token = AuthorizeGoogleApi.new('google_photo').get_service
  end

  def get_random_photo_url
    images, count = get_images_list
    random_index = rand(count)
    images[random_index]['baseUrl']
  end

  def get_album_id
    sample = @service.album
    sample.show
  end

  def get_album_list
    uri = URI.parse("https://photoslibrary.googleapis.com/v1/albums")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@access_token}"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts response.body
    response.body
  end

  def get_images_list
    album_id = ENV['ALBUM_ID']
    uri = URI.parse("https://photoslibrary.googleapis.com/v1/mediaItems:search")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{@access_token}"
    request.body = JSON.dump({
      "pageSize" => "200",
      "albumId" => album_id
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    result = JSON.parse(response.body)
    return result['mediaItems'], result['mediaItems'].length
  end

end