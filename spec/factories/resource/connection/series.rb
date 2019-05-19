# frozen_string_literal: true

FactoryBot.define do
  factory :resource_connection_series, class: 'Resource::Connection::Series' do
    resource { nil }
    series { nil }
  end
end
