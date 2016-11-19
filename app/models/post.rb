class Post < ApplicationRecord
  validates :title, presence: true

  scope :published, -> { where("published_at is not null") }
end
