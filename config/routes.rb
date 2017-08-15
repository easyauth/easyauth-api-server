Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :certificates, :users, :api_key_users
  post '/login', to: 'login#login'
  post '/api_login', to: 'login#api_login'
  get '/login', to: 'login#extend'
end
