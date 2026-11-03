class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 30, within: 1.minute, only: :create, with: -> { redirect_to new_session_path, alert: "Too many attempts. Try again shortly." }

  layout "auth"

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password])
      return_to = session[:return_to]
      sign_in(user)
      redirect_to return_to || root_path
    else
      flash.now[:alert] = "That email and password don't match."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    sign_out
    redirect_to new_session_path, notice: "Signed out."
  end
end
