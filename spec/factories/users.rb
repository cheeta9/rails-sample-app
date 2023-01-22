FactoryBot.define do
  factory :user do
    name { 'Example User' }
    email { 'user@example.com' }
    password { 'foobar' }
    password_confirmation { 'foobar' }
  end

  factory :other_user, class: User do
    name { 'Other User' }
    email { 'other_user@example.com' }
    password { 'hogefuga' }
    password_confirmation { 'hogefuga' }
  end

  factory :admin_user, class: User do
    name { 'Admin User' }
    email { 'admin_user@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
  end

  factory :index_user, class: User do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
