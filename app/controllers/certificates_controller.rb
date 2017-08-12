# Controller for Certificate views
class CertificatesController < ApplicationController
  include ActionController::MimeResponds
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
    certuser = @certificate.user
    unless @apiuser.admin? || certuser.id == @apiuser.id
      render json: {
        status: 'error',
        reason: 'Forbidden'
      }, status: 403
    end
    respond_to do |format|
      format.json do 
        render json: {
          status: 'success',
          certificate: {
            serial: @certificate.id,
            valid: @certificate.active?,
            valid_until: @certificate.valid_until,
            user: user_path(@certificate.user),
            download: certificate_path(@certificate, format: :pem)
          }
        }
      end
      format.pem do
        send_file(@certificate.path)
      end
    end
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
    render json: {status: 'error', reason: 'Invalid Certificate'}, status: 422 and return unless @certificate.active?
    render json: {status: 'error', reason: 'Bad parameters'}, status: 422 and return unless params[:valid] == "false"

    if @certificate.update(active: false, revoked: true, valid_until: Time.now)
      render :show, status: :ok, location: @certificate
    else
      render json: @certificate.errors, status: :unprocessable_entity
    end
  end

  # DELETE /certificates/1
  # DELETE /certificates/1.json
  def destroy
    if @apiuser.admin?
      File.delete(@certificate.path)
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
    @certificate = Certificate.find(params[:id])
  end

  def ca
    CA.instance
  end
end
