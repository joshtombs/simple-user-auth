Rails.application.routes.draw do

  root 'home#index'

  get "sign_in" => "authentication#sign_in"
  post "sign_in" => "authentication#login"
end
