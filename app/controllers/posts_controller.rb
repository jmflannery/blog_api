class PostsController < ApplicationController
  before_action :find_post, only: [:show]

  def index
    render json: Post.published
  end

  def show
    render json: @post
  end

  private

  def find_post
    @post = Post.published.find_by(id: params[:id])
    unless @post
      head :not_found
    end
  end
end
