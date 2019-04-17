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
    #puts response.body
    response.body
  end

  def get_images_list
    album_id = ENV['ALBUM_ID']
    images = [] # 写真格納用配列
    nextPageToken = ""
    uri = URI.parse("https://photoslibrary.googleapis.com/v1/mediaItems:search")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{@access_token}"
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    # 写真を全件取得する(page sizeが100までのため)
    loop do
      request.body = JSON.dump({
        "pageSize" => "100",
        "albumId" => album_id,
        "pageToken" => nextPageToken,
      })
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      #puts "Response body ===  #{response.body}"
      result = JSON.parse(response.body)
      images = images.concat(result['mediaItems'])
      nextPageToken = result['nextPageToken']
      if nextPageToken.nil?
        break
      end
    end
    
    return images, images.length
  end

end