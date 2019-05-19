# frozen_string_literal: true

FactoryBot.define do
  factory :category_topic, class: 'Category::Topic' do
    name { 'MyString' }
    category { nil }
  end
end
