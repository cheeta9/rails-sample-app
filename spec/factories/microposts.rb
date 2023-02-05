FactoryBot.define do
  factory :micropost do
    sequence(:content) { |n| "My Text #{n}." }
    user
  end

  factory :most_recent_micropost, class: Micropost do
    content { 'Most recent' }
    created_at { Time.zone.now }
    user { nil }
  end
end
