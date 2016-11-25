FactoryGirl.define do
  factory :token, class: Toke::Token do |token|
    key ''
    expires_at 5.years.from_now
  end
end
