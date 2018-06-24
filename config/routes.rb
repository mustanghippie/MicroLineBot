Rails.application.routes.draw do
  get 'schedule/ping'
  get 'sample/index'
  post '/callback' => 'linebot#callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
