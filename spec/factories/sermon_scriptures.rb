# frozen_string_literal: true

FactoryBot.define do
  factory :sermon_scripture, class: 'SermonScripture' do
    sermon { nil }
    scripture { nil }
  end
end
