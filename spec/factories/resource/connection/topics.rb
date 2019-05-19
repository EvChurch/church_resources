# frozen_string_literal: true

FactoryBot.define do
  factory :resource_connection_topic, class: 'Resource::Connection::Topic' do
    resource { nil }
    topic { nil }
  end
end
