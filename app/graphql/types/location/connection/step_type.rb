# frozen_string_literal: true

class Types::Location::Connection::StepType < Types::BaseObject
  graphql_name 'LocationConnectionStepType'

  field :content, String, null: true
  field :elvanto_form_id, String, null: true
  field :fluro_form_url, String, null: true
  field :id, ID, null: false
  field :location, Types::LocationType, null: false
  field :mail_chimp_audience_id, String, null: true
  field :mail_chimp_user_id, String, null: true
  field :step, Types::StepType, null: false
end
