class AuthenticationController < ApplicationController
  before_filter :check_signed_in, only: [:sign_in, :new_user]
  before_filter :ensure_signed_in, only: [:account_settings]

  def check_signed_in
    redirect_to :root unless !!session[:user_id].nil?
  end

  def ensure_signed_in
    redirect_to :root unless !session[:user_id].nil?
  end

  def sign_in
    @user = User.new
  end

  def signed_out
    user = User.find_by_id(session[:user_id])
    if user
      update_authentication_token(user, nil)
      user.save
      session[:user_id] = nil
      flash[:notice] = "You have been signed out."
    else
      redirect_to :sign_in
    end
  end

  def login
    @user = User.new
    username_or_email = params[:user][:username]
    password = params[:user][:password]

    if username_or_email.rindex('@')
      email=username_or_email
      user = User.authenticate_by_email(email, password)
    else
      username=username_or_email
      user = User.authenticate_by_username(username, password)
    end

    if user
      update_authentication_token(user, params[:user][:remember_me])
      user.save
      session[:user_id] = user.id
      flash[:notice] = 'Welcome!'
      redirect_to :root
    else
      #sign in failed
      flash[:error] = "Sign in failed. Please check username/password combination."
      render :action => "sign_in"
    end
  end

  def new_user
    @user = User.new
  end

  def register
    @user = User.new
    @user.username = params[:user][:username]
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.valid?
      update_authentication_token(@user, nil)
      @user.save
      session[:user_id] = @user.id
      flash[:notice] = 'Welcome.'
      redirect_to :root
    else
      render :action => "new_user"
    end
  end

  def update_authentication_token(user, remember_me)
    if remember_me == 1
      # create an authentication token if the user has clicked on remember me
      auth_token = SecureRandom.urlsafe_base64
      user.authentication_token = auth_token
      cookies.permanent[:auth_token] = auth_token
    else # nil or 0
      # if not, clear the token, as the user doesn't want to be remembered.
      user.authentication_token = nil
      cookies.permanent[:auth_token] = nil
    end
  end

  def current_user
    # Note: we want to use "find_by_id" because it's OK to return a nil.
    # If we were to use User.find, it would throw an exception if the user can't be found.
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    @current_user ||= User.find_by_authentication_token(cookies[:auth_token]) if cookies[:auth_token] && @current_user.nil?
    @current_user
  end

  def account_settings
    @user = current_user
  end

  def set_account_info
    old_user = current_user

    # verify the current password by creating a new user record.
    @user = User.authenticate_by_username(old_user.username, params[:user][:password])

    # verify
    if @user.nil?
      @user = current_user
      @user.errors[:password] = "Password is incorrect."
      render :action => "account_settings"
    else
      # update the user with any new username and email
      @user.username = params[:user][:username]
      @user.email = params[:user][:email]
      @user.new_password = params[:user][:new_password]
      @user.new_password_confirmation = params[:user][:new_password_confirmation]
      # Set the old email and username, which is validated only if it has changed.
      @user.previous_email = old_user.email
      @user.previous_username = old_user.username

      if @user.valid?
        # If there is a new_password value, then we need to update the password.
        @user.password = @user.new_password unless @user.new_password.nil? || @user.new_password.empty?
        @user.save
        flash[:notice] = 'Account settings have been changed.'
        redirect_to :root
      else
        render :action => "account_settings"
      end
    end
  end
end
