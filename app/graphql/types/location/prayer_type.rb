# frozen_string_literal: true

class Types::Location::PrayerType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :id, ID, null: false
  field :name, String, null: false
  field :snippet, String, null: false
  field :content, String, null: true
  field :location, Types::LocationType, null: false
  field :banner_url, String, null: false

  def banner_url
    polymorphic_url(object.banner)
  end
end
