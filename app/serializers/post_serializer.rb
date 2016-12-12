class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :published_at
end
