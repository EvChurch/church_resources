# frozen_string_literal: true

class Types::ScriptureType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :sermons, Types::SermonType.connection_type, null: false
end
