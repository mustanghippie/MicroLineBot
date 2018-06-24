Rails.application.routes.draw do
  get 'sample/index'
  get 'sample/error_screen'
  post '/callback' => 'linebot#callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
