FactoryGirl.define do
  factory :post do
    title 'Test Title'
    content 'Test content'
  end

  factory :published_post, class: Post do
    title 'Test Title Published'
    content 'Test content published'
    published_at { 1.day.ago }
  end
end
