Rails.application.routes.draw do

  root 'home#index'

  get "sign_in" => "authentication#sign_in"
  post "sign_in" => "authentication#login"

  get "signed_out" => "authentication#signed_out"
  get "new_user" => "authentication#new_user"

  put "new_user" => "authentication#register"
end
