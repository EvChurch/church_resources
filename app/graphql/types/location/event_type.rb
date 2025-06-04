# frozen_string_literal: true

class Types::Location::EventType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :address, String, null: false
  field :banner_url, String, null: false
  field :content, String, null: false
  field :elvanto_form_id, String, null: true
  field :end_at, GraphQL::Types::ISO8601DateTime, null: false
  field :facebook_url, String, null: true
  field :id, ID, null: false
  field :location, Types::LocationType, null: false
  field :name, String, null: false
  field :registration_url, String, null: true
  field :start_at, GraphQL::Types::ISO8601DateTime, null: false

  def banner_url
    polymorphic_url(
      object.banner.variant(
        convert: 'jpg', saver: { quality: 80 }, strip: true, resize_to_limit: [1920, 1080]
      )
    )
  end
end
