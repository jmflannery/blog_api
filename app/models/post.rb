class Post < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :published, -> { where.not(published_at: nil) }

  def publish(published_at = Time.zone.now)
    self.update published_at: published_at
  end
end
