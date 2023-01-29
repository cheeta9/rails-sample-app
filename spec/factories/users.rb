FactoryBot.define do
  factory :user do
    name { 'Example User' }
    email { 'user@example.com' }
    password { 'foobar' }
    password_confirmation { 'foobar' }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :other_user, class: User do
    name { 'Other User' }
    email { 'other_user@example.com' }
    password { 'hogefuga' }
    password_confirmation { 'hogefuga' }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :admin_user, class: User do
    name { 'Admin User' }
    email { 'admin_user@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :not_activated_user, class: User do
    name { 'Not Activated User' }
    email { 'not_activated_user@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
    activated { false }
    activated_at { nil }
  end

  factory :index_user, class: User do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    activated { true }
    activated_at { Time.zone.now }
  end
end
