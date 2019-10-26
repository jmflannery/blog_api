class PostsController < ApplicationController
  before_action :toke!, only: [:create, :update, :destroy, :publish]

  before_action only: :index do
    toke! do |errors|
      render json: Post.published, each_serializer: serializer
    end
  end

  before_action only: :show do
    toke! do |errors|
      @post = Post.published.find_by(id:   params[:id])
      @post = Post.published.find_by(slug: params[:id]) unless @post
      render json: { errors: { post_id: 'Post not found' }}, status: :not_found unless @post
    end
  end

  before_action :find_post, only: [:show, :update, :destroy, :publish]
  before_action :find_tags, only: [:create]

  def create
    post = Post.new(post_params)
    if post.save
      if @tags
        @tags.each { |tag| post.tags << tag }
      end
      render json: post, status: :created
    else
      render json: { errors: post.errors }, status: :bad_request
    end
  end

  def index
    render json: Post.all, each_serializer: serializer
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
    params.require('post').permit(['title', 'slug', 'content', 'published_at'])
  end

  def find_post
    @post = Post.find_by(id:   params[:id])
    @post = Post.find_by(slug: params[:id]) unless @post
    render json: { errors: { post_id: 'Post not found' }}, status: :not_found unless @post
  end

  def find_tags
    return unless params[:tags]
    @tags = Tag.find(params[:tags])
  end

  def serializer
    if params[:type] == 'list'
      Posts::ListItemSerializer
    else
      PostSerializer
    end
  end
end
