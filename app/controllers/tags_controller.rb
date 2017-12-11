class TagsController < ApplicationController
  before_action :toke!
  before_action :find_tag, only: :destroy

  def create
    tag = Tag.new(tag_params)
    if tag.save
      render json: tag, status: :created
    else
      render json: { errors: tag.errors }, status: :bad_request
    end
  end

  def destroy
    @tag.destroy
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end

  def find_tag
    return unless params[:id]
    @tag = Tag.find_by id: params[:id]
    render json: { errors: { id: 'Tag not found' }}, status: :not_found unless @tag
  end
end
