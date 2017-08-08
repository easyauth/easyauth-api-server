# Shared methods for all controllers
class ApplicationController < ActionController::API
  include APIKey

  protected

  def require_auth
    api_user_id = validate_api_key(params[:apikey])
    if api_user_id && User.exists?(api_user_id)
      @apiuser = User.find(api_user_id)
    else
      delete_api_key(params[:apikey])
      render json: {
        status: 'error',
        error: 'Unauthorized'
      }, status: 401
    end
  end
end
