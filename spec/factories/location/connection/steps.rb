# frozen_string_literal: true

FactoryBot.define do
  factory :location_connection_step, class: 'Location::Connection::Step' do
    form_url { 'MyString' }
    content { 'MyText' }
    step { nil }
    location { nil }
  end
end
