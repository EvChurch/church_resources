# frozen_string_literal: true

class Types::Location::ServiceType < Types::BaseObject
  field :elvanto_form_id, String, null: true
  field :end_at, String, null: false
  field :id, ID, null: false
  field :location, Types::LocationType, null: false
  field :start_at, String, null: false
end
