# frozen_string_literal: true

class Types::Location::EventType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :id, ID, null: false
  field :start_at, String, null: false
  field :end_at, String, null: false
  field :address, String, null: false
  field :name, String, null: false
  field :snippet, String, null: false
  field :content, String, null: false
  field :form_url, String, null: true
  field :facebook_url, String, null: true
  field :banner_url, String, null: false
  field :location, Types::LocationType, null: false

  def banner_url
    polymorphic_url(object.banner)
  end
end
