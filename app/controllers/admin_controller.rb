class AdminController < ApplicationController
  before_filter :ensure_admin
  
  def ensure_admin
    redirect_to :root unless !session[:user_id].nil?
  end

  def users
    @users = User.all
  end

  def delete_user
    if params[:id] == current_user.id.to_s
      flash.now[:error] = 'You cannot delete yourself!'
      @users = User.all
      render :action => :users
    else
      User.find_by_id(params[:id]).delete
      @users = User.all
      render :action => :users
    end
  end
end
