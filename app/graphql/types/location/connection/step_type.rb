# frozen_string_literal: true

class Types::Location::Connection::StepType < Types::BaseObject
  graphql_name 'LocationConnectionStepType'

  field :id, ID, null: false
  field :content, String, null: true
  field :location, Types::LocationType, null: false
  field :step, Types::StepType, null: false
  field :form_url, String, null: false
end
