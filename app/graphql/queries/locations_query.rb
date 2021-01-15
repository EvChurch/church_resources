# frozen_string_literal: true

class Queries::LocationsQuery < Queries::BaseQuery
  type Types::LocationType.connection_type, null: false
  argument :ids, [ID], required: false

  def resolve(ids: nil)
    scope(ids).all
  end

  protected

  def scope(ids)
    scope = ::Location
    filter_by_ids(scope, ids)
  end

  def filter_by_ids(scope, ids)
    ids.present? ? scope.where(id: ids) : scope
  end
end
