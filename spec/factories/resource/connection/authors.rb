# frozen_string_literal: true

FactoryBot.define do
  factory :resource_connection_author, class: 'Resource::Connection::Author' do
    resource { nil }
    author { nil }
  end
end
