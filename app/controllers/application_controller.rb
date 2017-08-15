# Shared methods for all controllers
class ApplicationController < ActionController::API
  include APIKey

  protected

  def set_default_request_format
    request.format = :json unless params[:format]
  end

  def require_auth
    if ApiKeyUser.where(public_key: params[:apikey]).any?
      @apiuser_is_public = true
      @apiuser = ApiKeyUser.find_by(public_key: params[:apikey])
      if validate_hmac
        return
      else
        render json: {
          status: 'error',
          error: 'Unauthorized'
        }, status: 401
        return
      end
    end
    @apiuser_is_public = false
    api_user = validate_api_key(params[:apikey])
    if api_user
      @apiuser = api_user
    else
      delete_api_key(params[:apikey])
      render json: {
        status: 'error',
        error: 'Unauthorized'
      }, status: 401
    end
  end

  def forbid_public_user
    return unless @apiuser_is_public || @apiuser.is_a?(ApiKeyUser)
    render json: {
        status: 'error',
        error: 'Forbidden'
    }, status: 403
  end

  private

  def validate_hmac
    require 'openssl'
    return false if params[:nonce].nil? || params[:id].nil?
    key = @apiuser.secret_key
    data = params[:nonce].to_s + params[:id].to_s
    mac = OpenSSL::HMAC.hexdigest("SHA256", key, data)
    mac == params[:hmac]
  end
end
