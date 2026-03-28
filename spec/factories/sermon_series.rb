# frozen_string_literal: true

FactoryBot.define do
  factory :sermon_series_connection, class: 'SermonSeries' do
    sermon { nil }
    series { nil }
  end
end
