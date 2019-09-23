# frozen_string_literal: true

FactoryBot.define do
  factory :location_prayer, class: 'Location::Prayer' do
    name { 'MyString' }
    snippet { 'MyString' }
    content { 'MyText' }
    location { nil }
  end
end
