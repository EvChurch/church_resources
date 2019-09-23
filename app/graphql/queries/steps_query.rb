# frozen_string_literal: true

class Queries::StepsQuery < Queries::BaseQuery
  type Types::StepType.connection_type, null: false

  def resolve
    scope.all
  end

  protected

  def scope
    ::Step
  end
end
