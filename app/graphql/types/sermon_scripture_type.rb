# frozen_string_literal: true

class Types::SermonScriptureType < Types::BaseObject
  field :content, String, null: false
  field :id, ID, null: false
  field :range, String, null: true
  field :sermon, Types::SermonType, null: false
  field :scripture, Types::ScriptureType, null: false
end
