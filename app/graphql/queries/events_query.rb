# frozen_string_literal: true

class Queries::EventsQuery < Queries::BaseQuery
  type Types::Location::EventType.connection_type, null: false
  argument :ids, [ID], required: false
  argument :location_ids, [ID], required: false

  def resolve(ids: nil, location_ids: nil)
    scope(ids, location_ids).all
  end

  protected

  def scope(ids, location_ids)
    scope = ::Location::Event.upcoming
    scope = filter_by_ids(scope, ids)
    scope = filter_by_locations(scope, location_ids)

    scope
  end

  def filter_by_ids(scope, ids)
    ids.present? ? scope.where(id: ids) : scope
  end

  def filter_by_locations(scope, ids)
    ids.present? ? scope.where(location_id: ids) : scope
  end
end
