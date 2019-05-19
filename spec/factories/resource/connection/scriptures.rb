# frozen_string_literal: true

FactoryBot.define do
  factory :resource_connection_scripture, class: 'Resource::Connection::Scripture' do
    resource { nil }
    author { nil }
  end
end
