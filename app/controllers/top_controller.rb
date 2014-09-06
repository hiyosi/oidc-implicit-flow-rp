class TopController < ApplicationController

  def index
    redirect_to '/after_login' unless @id_token.blank?
  end

  def after_login
    redirect_to '/authz' if session[:id_token].blank?
    @id_token = session[:id_token]
    @user_info = session[:user_info]
  end

  def after_logout
  end

end
