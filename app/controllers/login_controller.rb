# Handles logging in and extending API key validity
class LoginController < ApplicationController
  before_action :set_default_request_format
  # Allows a user to log in
  def login
    if params[:email].nil? || params[:password].nil?
      @error = 'Must specify username and password'
      render status: 401
      return
    end

    @user = User.find_by(email: params[:email])
    unless @user && @user.authenticate(params[:password])
      @error = 'Incorrect username or password'
      render status: 401
      return
    end
    @apikey, @expires = create_api_key(@user)
  end

  # Allows a user to log in
  def api_login
    if params[:email].nil? || params[:password].nil?
      @error = 'Must specify username and password'
      render status: 401
      return
    end

    @user = ApiKeyUser.find_by(email: params[:email])
    unless @user && @user.authenticate(params[:password])
      @error = 'Incorrect username or password'
      render status: 401
      return
    end
    puts "user class: #{@user.class} user id: #{@user.id}"
    @apikey, @expires = create_api_key(@user)
  end

  # Allows a user to extend their API key validity
  def extend
    @expires = extend_api_key(params[:apikey])
    return if @expires
    @error = 'Invalid API key'
    render status: 401
  end
end
