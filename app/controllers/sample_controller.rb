class SampleController < ApplicationController
  require 'logger'
  def index
  	logger1 = Logger.new(STDERR)
  	logger1.debug('デプロイチェック')
  	#redirect_to :action => 'error_screen'
  end

  def error_screen
    logger.debug('---Bad request---')
    head :bad_request
  end
end
