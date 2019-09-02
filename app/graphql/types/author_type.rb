# frozen_string_literal: true

class Types::AuthorType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :resources, [ResourceType], null: false
end
