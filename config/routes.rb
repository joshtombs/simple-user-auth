Rails.application.routes.draw do

  root 'home#index'

  namespace :admin, :module => false do
    get "sign_in" => "admin#sign_in"
    post "sign_in" => "admin#login"
    get "signed_out" => "admin#signed_out"
    get "account_settings" => "admin#account_settings"
    put "account_settings" => "admin#set_account_info"
    get "users" => "admin#users"
    delete "user/:id" => "admin#delete_user"
  end

  get "sign_in" => "authentication#sign_in"
  post "sign_in" => "authentication#login"

  get "signed_out" => "authentication#signed_out"
  get "new_user" => "authentication#new_user"
  put "new_user" => "authentication#register"

  get "account_settings" => "authentication#account_settings"
  put "account_settings" => "authentication#set_account_info"

  get "forgot_password" => "authentication#forgot_password"
  put "forgot_password" => "authentication#send_password_reset_instructions"

  get "password_reset" => "authentication#password_reset"
  put "password_reset" => "authentication#new_password"
end
