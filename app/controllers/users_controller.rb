class UsersController < ApplicationController
  def create
    @user = User.new(register_params)
    if @user.save
      @user.password_digest = nil
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
  def change_password
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:current_password])
      @user.password = params[:new_password]
      @user.password_confirmation = params[:new_password_confirmation]
      if @user.valid?
        @user.save
        render json: { message: 'Password successfully updated' }, status: :ok
      else
        error_message = @user.errors.full_messages.join(", ")
        render json: { error: error_message }, status: :unprocessable_entity
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
