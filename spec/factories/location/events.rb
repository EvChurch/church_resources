# frozen_string_literal: true

FactoryBot.define do
  factory :location_event, class: 'Location::Event' do
    start_at { '2019-09-23 12:01:19' }
    end_at { '2019-09-23 12:01:19' }
    name { 'MyString' }
    snippet { 'MyString' }
    content { 'MyText' }
    address { 'MyString' }
    form_url { 'MyString' }
    facebook_url { 'MyString' }
    location { nil }
  end
end
