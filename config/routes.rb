Rails.application.routes.draw do
  get 'sample/index'
  post '/callback' => 'linebot#callback'
end
