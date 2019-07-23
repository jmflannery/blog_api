module Posts
  class ListItemSerializer < ActiveModel::Serializer
    attributes :id, :title, :slug, :published_at
  end
end
