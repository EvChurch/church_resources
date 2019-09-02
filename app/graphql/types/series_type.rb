# frozen_string_literal: true

class Types::SeriesType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :resources, [ResourceType], null: false
  field :banner_url, String
  field :foreground_url, String
  field :background_url, String
end
