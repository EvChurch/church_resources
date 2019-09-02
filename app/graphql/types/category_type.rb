# frozen_string_literal: true

class Types::CategoryType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :topics, Types::TopicType.connection_type, null: false
  field :resources, Types::ResourceType.connection_type, null: false
end
