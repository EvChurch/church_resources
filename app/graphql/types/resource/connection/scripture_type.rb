# frozen_string_literal: true

class Types::Resource::Connection::ScriptureType < Types::BaseObject
  graphql_name 'ResourceConnectionScriptureType'

  field :content, String, null: false
  field :id, ID, null: false
  field :range, String, null: true
  field :resource, Types::ResourceType, null: false
  field :scripture, Types::ScriptureType, null: false
end
