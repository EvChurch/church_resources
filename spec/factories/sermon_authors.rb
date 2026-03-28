# frozen_string_literal: true

FactoryBot.define do
  factory :sermon_author, class: 'SermonAuthor' do
    sermon { nil }
    author { nil }
  end
end
