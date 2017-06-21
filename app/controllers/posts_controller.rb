class PostsController < ApplicationController
  before_action :toke!, only: [:create, :update, :destroy, :publish]

  before_action only: :index do
    toke! do |errors|
      render json: Post.published
    end
  end

  before_action only: :show do
    toke! do |errors|
      @post = Post.published.find_by id: params[:id]
      render json: { errors: { post_id: 'Post not found' }}, status: :not_found unless @post
    end
  end

  before_action :find_post, only: [:show, :update, :destroy, :publish]

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

  def publish
    @post.publish
    render json: @post
  end

  private

  def post_params
    params.require('post').permit(['title', 'content', 'published_at'])
  end

  def find_post
    @post = Post.find_by(id: params[:id])
    render json: { errors: { post_id: 'Post not found' }}, status: :not_found unless @post
  end
end
