Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/callback' => 'linebot#callback'
  post '/callback2' => 'linebot2#callback'
  get '/liff' => 'liff#index'
end
