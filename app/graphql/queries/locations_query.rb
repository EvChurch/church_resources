# frozen_string_literal: true

class Queries::LocationsQuery < Queries::BaseQuery
  type Types::LocationType.connection_type, null: false

  def resolve
    scope.all
  end

  protected

  def scope
    ::Location
  end
end
