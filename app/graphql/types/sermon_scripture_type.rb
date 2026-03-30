# frozen_string_literal: true

class Types::SermonScriptureType < Types::BaseObject
  field :content, String, null: true
  field :id, ID, null: false
  field :range, String, null: true
  field :scripture, Types::ScriptureType, null: false
  field :sermon, Types::SermonType, null: false
end
