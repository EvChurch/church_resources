# frozen_string_literal: true

class Types::Location::EventType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :id, ID, null: false
  field :start_at, GraphQL::Types::ISO8601DateTime, null: false
  field :end_at, GraphQL::Types::ISO8601DateTime, null: false
  field :address, String, null: false
  field :name, String, null: false
  field :content, String, null: false
  field :elvanto_form_id, String, null: true
  field :facebook_url, String, null: true
  field :registration_url, String, null: true
  field :banner_url, String, null: false
  field :location, Types::LocationType, null: false

  def banner_url
    polymorphic_url(
      object.banner.variant(
        convert: 'jpg', saver: { quality: 80 }, strip: true, resize_to_limit: [1920, 1080]
      )
    )
  end
end
