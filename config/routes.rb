Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :certificates, :users
  post '/login', to: 'login#login'
  get '/login', to: 'login#extend'
end
