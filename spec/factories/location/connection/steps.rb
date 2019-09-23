# frozen_string_literal: true

FactoryBot.define do
  factory :location_connection_step, class: 'Location::Connection::Step' do
    elvanto_form_id { 'MyString' }
    content { 'MyText' }
    step { nil }
    location { nil }
  end
end
