# Controller for Certificate views
class CertificatesController < ApplicationController
  before_action :set_default_request_format
  before_action :require_auth, only: %i[show create update destroy]
  before_action :set_certificate, only: %i[show update destroy]

  def set_default_request_format
    request.format = :json unless params[:format]
  end

  # GET /certificates
  # GET /certificates.json
  def index
    render json: {
      error: 'Method not allowed'
    }, status: 405
  end

  # GET /certificates/1
  # GET /certificates/1.json
  def show
    certuser = User.find(@certificate.User)
    unless certuser.admin? || certuser.id == apiuser.id
      render json: {
        status: 'error',
        reason: 'Forbidden'
      }, status: 403
    end
    render json: {
      blah: 'blah'
    }
  end

  # POST /certificates
  # POST /certificates.json
  def create
    @certificate = Certificate.new(certificate_params)

    if @certificate.save
      render :show, status: :created, location: @certificate
    else
      render json: @certificate.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /certificates/1
  # PATCH/PUT /certificates/1.json
  def update
    if @certificate.update(certificate_params)
      render :show, status: :ok, location: @certificate
    else
      render json: @certificate.errors, status: :unprocessable_entity
    end
  end

  # DELETE /certificates/1
  # DELETE /certificates/1.json
  def destroy
    @certificate.destroy
  end

  private

  def require_auth
    unless (defined? params[:apikey]) && redis.exists(params[:apikey])
      render json: {
        error: 'Unauthorized'
      }, status: 401
      return
    end
    puts (defined? params[:apikey]) && redis.exists(params[:apikey])
    apiuserid = redis.get(params[:apikey])
    @apiuser = User.find(apiuserid)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_certificate
    #@certificate = Certificate.find(params[:serial])
  end

  # Never trust parameters from the scary internet, only allow the whitelist.
  def certificate_params
    params.fetch(:certificate, {})
  end

  def redis
    Redis.current
  end
end
