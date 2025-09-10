class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt
  rescue_from StandardError, with: :internal_error
  rescue_from ActiveRecord::RecordInvalid, with: :bad_request
  
  private
  def authenticate_jwt
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JwtServices.decode(token)
    unless payload
      render json: { error: "Invalid or missing token" }, status: :unauthorized and return
    end
    @current_user = User.find(payload['user_id'])
  end

  def internal_error(exception)
    render json: { error: "Internal server error", details: exception.message }, status: :internal_server_error
  end

  def bad_request(exception)
    render json: { error: "Bad request", details: exception.message }, status: :bad_request
  end
end
