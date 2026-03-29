# frozen_string_literal: true

FactoryBot.define do
  factory :sermon, class: 'Sermon' do
    name { 'MyString' }
    published_at { '2019-05-20 10:10:27' }
  end
end
