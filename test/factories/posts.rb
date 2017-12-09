FactoryGirl.define do
  factory :post do
    title 'Test Title'
    sequence(:slug) {|n| "test-title-#{n}" }
    content 'Test content'
  end

  factory :published_post, class: Post do
    title 'Test Title Published'
    sequence(:slug) {|n| "test-title-published-#{n}" }
    content 'Test content published'
    published_at { 1.day.ago }
  end
end
