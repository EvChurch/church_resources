# frozen_string_literal: true

FactoryBot.define do
  factory :location_service, class: 'Location::Service' do
    start_at { '2019-09-23 12:00:06' }
    end_at { '2019-09-23 12:00:06' }
    location { nil }
  end
end
