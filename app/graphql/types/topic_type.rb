# frozen_string_literal: true

class Types::TopicType < Types::BaseObject
  field :category, Types::CategoryType, null: false
  field :id, ID, null: false
  field :name, String, null: false
  field :resources, Types::ResourceType.connection_type, null: false
end
