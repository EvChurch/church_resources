# frozen_string_literal: true

class Types::Location::ServiceType < Types::BaseObject
  field :id, ID, null: false
  field :start_at, String, null: false
  field :end_at, String, null: false
  field :form_url, String, null: true
  field :location, Types::LocationType, null: false
end
