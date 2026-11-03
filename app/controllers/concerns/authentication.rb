module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    helper_method :current_user, :signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_login, **options
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def require_login
    return if signed_in?

    session[:return_to] = request.fullpath if request.get?
    redirect_to new_session_path
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
  end

  def sign_out
    reset_session
    @current_user = nil
  end
end
