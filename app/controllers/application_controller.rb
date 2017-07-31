class ApplicationController < ActionController::API
  include APIKey

  protected

  def require_auth
    api_user_id = validate_api_key(params[:apikey])
    unless api_user_id
      render json: {
        status: 'error',
        error: 'Unauthorized'
      }, status: 401
      return
    end
    @apiuser = User.find(api_user_id)
  end
end
