# frozen_string_literal: true

class Types::SeriesType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :resources, Types::ResourceType.connection_type, null: false
  field :banner_url, String, null: true
  field :foreground_url, String, null: true
  field :background_url, String, null: true
end
