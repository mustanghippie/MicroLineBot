class UserRegistration
  require 'logger'
  
  def initialize(event)
    logger = Logger.new(STDERR)
    #logger.debug("イベント #{event.message}")  
    #logger.debug("イベント #{event.linebot}")
    logger.debug("ソース #{event['source']}")

    #logger.debug("ユーザーID #{events[0]['source']['userId']}")

    source
  end

  def get_user_id

  end

end