# frozen_string_literal: true

FactoryBot.define do
  factory :resource do
    type { '' }
    name { 'MyString' }
    snippet { 'MyString' }
    content { 'MyText' }
    published_at { '2019-05-20 10:10:27' }
    video_url { 'MyString' }
  end
end
