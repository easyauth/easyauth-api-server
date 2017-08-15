class ApiKeyUsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :require_auth, only: %i[index show update destroy]
  before_action :set_default_request_format
  before_action :forbid_public_user, only: %i[index]
  before_action :forbid_other_public_user, except: %i[index create]

  def index
    unless @apiuser.admin?
      render json: { status: 'error', error: 'Forbidden' }, status: 403
      return
    end
    @users = if params[:start].nil?
               ApiKeyUser.limit(100)
             else
               ApiKeyUser.limit(100).offset(params[:start].to_i)
             end
  end

  def show; end

  def create
    require 'securerandom'
    public_key = SecureRandom.hex(48)
    secret_key = SecureRandom.hex(48)
    @user = ApiKeyUser.new(email: params[:email],
                           password: params[:password],
                           validated: false,
                           public_key: public_key,
                           secret_key: secret_key
                           )

    if @user.save
      ApiEmailValidation.generate(@user, EmailValidationsTypes::API_CREATE)
      render json: {
        status: 'queued',
        url: api_key_user_url(@user) 
      }, status: :accepted
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    unless @apiuser == @user || @apiuser.admin?
      render json: {
        status: 'error',
        error: 'Forbidden'
      }, status: 403
    end

    unless params[:validation_code].nil?
      return unless (@action = validate_user)
    end

    update_user

    if (defined? @action) && @action == EmailValidationsTypes::API_DELETE
      validations = ApiEmailValidation.where(api_key_user: @user)
      validations.each(&:destroy)
      @user.destroy
    elsif @user.save
      render :show, status: if params[:email].nil?
                              :ok
                            else
                              :accepted
                            end, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    unless @apiuser == @user || @apiuser.admin?
      render json: {
        status: 'error',
        error: 'Forbidden'
      }, status: 403
    end
    ApiEmailValidation.generate(@user, EmailValidationsTypes::API_DELETE)
    render :show, status: :accepted, location: @user
  end

  private

  def forbid_other_public_user
    return unless @apiuser_is_public
    return if (@apiuser.is_a? ApiKeyUser && @apiuser.id == @user.id) ||
              (@apiuser.is_a? User && @apiuser.admin?)
    render json: {
        status: 'error',
        error: 'Forbidden'
    }, status: 403
  end

  def validate_user
    validation = ApiEmailValidation.find_by(code: params[:validation_code])
    if validation.nil? || validation.api_key_user != @apiuser
      render json: {
        status: 'error', error: 'Bad validation code'
      }, status: 422
      return false
    end

    if validation.action == EmailValidationsTypes::API_CREATE ||
       validation.action == EmailValidationsTypes::API_CHANGE
      @user.validated = true
      @user.email = validation.new_email if validation.action == EmailValidationsTypes::API_CHANGE
    end
    action = validation.action
    validation.destroy
    action
  end

  def update_user
    ApiEmailValidation.generate(@user, EmailValidationsTypes::API_CHANGE, params[:email]) unless params[:email].nil?
    @user.password = params[:password] unless params[:password].nil?
  end

  def set_user
    @user = ApiKeyUser.find(params[:id])
  end
end