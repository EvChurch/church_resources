# frozen_string_literal: true

class Types::CategoryType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :topics, [TopicType], null: false
end
