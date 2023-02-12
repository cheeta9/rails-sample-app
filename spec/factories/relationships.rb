FactoryBot.define do
  factory :relationship do
    follower { association :user }
    followed { association :other_user }
  end
end
