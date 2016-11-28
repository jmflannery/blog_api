FactoryGirl.define do
  factory :token, class: Toker::Token do |token|
    key ''
    expires_at 5.years.from_now
  end
end
