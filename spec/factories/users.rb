# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "testuser#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :admin do
      after(:create) do |user|
        # Ensure the 'admin' role exists in the roles table
        Role.find_or_create_by!(name: 'admin')
        user.add_role(:admin) # Assign the global admin role
      end
    end
  end
end
