class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :content, :published_at
  has_many :tags
end
