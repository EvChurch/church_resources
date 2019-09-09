# frozen_string_literal: true

class Types::BaseObject < GraphQL::Schema::Object
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end
