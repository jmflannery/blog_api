class Admin::PostsController < ApplicationController
  before_action :find_post, only: [:show, :update, :destroy]
  before_action :toke!

  def create
    post = Post.new(post_params)
    if post.save
      render json: post, status: :created
    else
      render json: { errors: post.errors }, status: :bad_request
    end
  end

  def index
    posts = Post.all
    render json: posts
  end

  def show
    render json: @post
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors }, status: :bad_request
    end
  end

  def destroy
    @post.destroy
    head :no_content
  end

  private

  def post_params
    params.require('post').permit(['title', 'content'])
  end

  def find_post
    @post = Post.find_by(id: params[:id])
    unless @post
      head :not_found
    end
  end
end
