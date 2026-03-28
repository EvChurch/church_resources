# frozen_string_literal: true

FactoryBot.define do
  factory :sermon_topic, class: 'SermonTopic' do
    sermon { nil }
    topic { nil }
  end
end
