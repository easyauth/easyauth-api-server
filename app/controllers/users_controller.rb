# Dispatch users
class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :require_auth, only: %i[index show update destroy]
  before_action :set_default_request_format

  def set_default_request_format
    request.format = :json unless params[:format]
  end

  # GET /users
  # GET /users.json
  def index
    unless @apiuser.admin?
      render json: { status: 'error', error: 'Forbidden' }, status: 403
      return
    end
    @users = if params[:start].nil?
               User.limit(100)
             else
               User.limit(100).offset(params[:start].to_i)
             end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    unless @apiuser.id == @user.id || @apiuser.admin?
      render json: {
        status: 'error',
        error: 'Forbidden'
      }, status: 403
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(name: params[:name],
                     email: params[:email],
                     password: params[:password], admin: false,
                     validated: false)

    if @user.save
      EmailValidation.generate(@user, EmailValidationsTypes::CREATE)
      render :show, status: :accepted, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    unless (@apiuser.id == @user.id && !params[:admin].nil?) ||
           !@apiuser.admin?
      render json: {
        status: 'error',
        error: 'Forbidden'
      }, status: 403
      return
    end

    unless params[:validation_code].nil?
      return unless (@action = validate_user)
    end

    update_user

    if (defined? @action) && @action == EmailValidationsTypes.DELETE
      validations = email_validation.where(user: @user)
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

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    unless @apiuser.id == @user.id || @apiuser.admin?
      render json: {
        status: 'error',
        error: 'Forbidden'
      }, status: 403
    end
    validation.generate(@user, EmailValidationsTypes::DELETE)
    render :show, status: :accepted, location: @user
  end

  private

  def validate_user
    validation = EmailValidation.find_by(code: params[:validation_code])
    if validation.nil? || validation.user.id != @apiuser.id
      render json: {
        status: 'error', error: 'Bad validation code'
      }, status: 422
      return false
    end

    if validation.action == EmailValidationsTypes::CREATE ||
       validation.action == EmailValidationsTypes::CHANGE
      @user.validated = true
      @user.email = validation.new_email if validation.action == EmailValidationsTypes::CHANGE
    end
    validation.action
  end

  def update_user
    EmailValidation.generate(@user, EmailValidationsTypes::CHANGE, params[:email]) unless params[:email].nil?
    @user.name = params[:name] unless params[:name].nil?
    @user.password = params[:password] unless params[:password].nil?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def redis
    Redis.current
  end
end
