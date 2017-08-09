# Controller for Certificate views
class CertificatesController < ApplicationController
  before_action :set_default_request_format
  before_action :require_auth, only: %i[show create update destroy]
  before_action :check_current_cert, only: %i[create]
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
    unless @apiuser.admin? || certuser.id == apiuser.id
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
    csr = OpenSSL::X509::Request.new params[:csr]

    @certificate = ca.sign_csr(csr, @apiuser)

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
    if @apiuser.admin?
      @certificate.destroy
    else
      render json: {
        status: 'error',
        reason: 'forbidden'
      }, status: :forbidden
    end
  end

  private

  # Render 422 if a user still has an old certificate when creating a new one
  def check_current_cert
    results = Certificate.where(user: @apiuser, active: true)
    return unless results.exists?
    render json: {
      status: 'error',
      reason: 'Unrevoked certificate',
      revoke_url: url_for(results.first)
    }, status: :unprocessable_entity
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_certificate
    @certificate = Certificate.find(params[:serial])
  end

  # Never trust parameters from the scary internet, only allow the whitelist.
  def certificate_params
    params.fetch(:certificate, {})
  end

  def ca
    CA.instance
  end
end
