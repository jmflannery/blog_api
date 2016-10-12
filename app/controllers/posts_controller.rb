class PostsController < ApplicationController

  def create
    post = Post.new(post_attrs)
    if post.save
      render json: post, status: :created
    else
      render json: { error: post.errors }, status: :bad_request
    end
  end

  def index
    posts = Post.all
    render json: posts
  end

  def show
    post = Post.find_by(id: params[:id])
    if post
      render json: post
    else
      head :not_found
    end
  end

  private

  def post_attrs
    params.require('post').permit(['title', 'content'])
  end
end
