# frozen_string_literal: true

class Types::ResourceType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :authors, [AuthorType], null: false
  field :scriptures, [ScriptureType], null: false
  field :series, [SeriesType], null: false
  field :topics, [TopicType], null: false
end
