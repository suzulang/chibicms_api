class UsersController < ApplicationController
  def create
    @user = User.new(register_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
  def change_password
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:current_password])
      if @user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        render json: { message: 'Password successfully updated' }, status: :ok
      else
        render json: { error: @user.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid current password' }, status: :unprocessable_entity
    end
  end

  private

  def register_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
