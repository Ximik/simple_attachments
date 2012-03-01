class UsersController < ApplicationController
  before_filter :load_user

  def edit
  end
  
  def update
    @user.update_attributes params[:user]
    @user.save
    render :edit
  end

  private

  def load_user
    @user = User.find params[:id]
  end
end