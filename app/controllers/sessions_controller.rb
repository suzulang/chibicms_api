class SessionsController < ApplicationController
  def create
    @user = User.find_by(email: login_params[:email])
    if @user && @user.authenticate(login_params[:password])
      token = @user.generate_jwt
      render json: { token: token }, status: :ok
    else
      error_message = if @user.nil?
                        'Email not found'
                      else
                        'Invalid password'
                      end
      render json: { error: error_message }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
