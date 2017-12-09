class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :content, :published_at
end
