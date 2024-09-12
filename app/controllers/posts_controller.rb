class PostsController < ApplicationController
  def index
    decoded_token = JsonWebToken.decode(request.headers[:Authorization])
    if decoded_token
      user_id = decoded_token[:user_id]
      @posts = Post.where(user_id: user_id)
      render json: @posts
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def create
    decoded_token = JsonWebToken.decode(request.headers[:Authorization])
    if decoded_token
      user_id = decoded_token[:user_id]
      @post = Post.create(user_id: user_id, **post_params)
      render json: @post, status: :created
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def update
    decoded_token = JsonWebToken.decode(request.headers[:Authorization])
    if decoded_token
      user_id = decoded_token[:user_id]
      @post = Post.find_by(id: params[:id])
      
      if @post.nil?
        render json: { error: '帖子未找到' }, status: :not_found
      elsif @post.user_id != user_id
        render json: { error: '无权限更新此帖子' }, status: :unauthorized
      else
        if @post.update(post_params)
          render json: @post
        else
          render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end
    else
      render json: { error: '无效的token' }, status: :unauthorized
    end
  end
 
  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
