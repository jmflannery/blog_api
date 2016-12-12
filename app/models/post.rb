class Post < ApplicationRecord
  validates :title, presence: true

  scope :published, -> { where("published_at is not null") }

  def publish(published_at = Time.zone.now)
    self.update published_at: published_at
  end
end
