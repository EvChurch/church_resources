# frozen_string_literal: true

class Types::TopicType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :category, CategoryType, null: false
  field :resources, [ResourceType], null: false
end
