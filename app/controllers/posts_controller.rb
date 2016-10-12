class PostsController < ApplicationController

  def create
    post = Post.new(post_attrs)
    if post.save
      render json: post, status: :created
    else
      render json: { error: post.errors }, status: :bad_request
    end
  end

  private

  def post_attrs
    params.require('post').permit(['title', 'content'])
  end
end
