class PostsController < ApplicationController
  before_action :toke!, only: [:create, :update, :destroy]
  before_action :find_post, only: [:update, :destroy]

  before_action only: :index do
    toke! do |errors|
      render json: Post.published
    end
  end

  before_action only: :show do
    toke! do |errors|
      @posts = Post.published
    end
  end

  before_action :get_post, only: :show

  def create
    post = Post.new(post_params)
    if post.save
      render json: post, status: :created
    else
      render json: { errors: post.errors }, status: :bad_request
    end
  end

  def index
    render json: Post.all
  end

  def show
    post = @posts.where
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

  def get_post
    @posts ||= Post.all
    @post = @posts.find_by(id: params[:id])
    head :not_found unless @post
  end

  def find_post
    @post = Post.find_by(id: params[:id])
    head :not_found unless @post
  end
end
