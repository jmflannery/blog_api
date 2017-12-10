class TagsController < ApplicationController
  before_action :toke!

  def create
    tag = Tag.new(tag_params)
    if tag.save
      render json: tag, status: :created
    else
      render json: { errors: tag.errors }, status: :bad_request
    end
  end

  def destroy
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
