class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  
  def show
    @user = User.find(params[:id])
  end
  
  def dashboard
    @users = User.all
  end

  def refresh_table
    @users = User.all
    respond_to do |format|
      format.js
    end
  end
  
end