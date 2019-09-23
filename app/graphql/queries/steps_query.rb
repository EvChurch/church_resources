# frozen_string_literal: true

class Queries::StepsQuery < Queries::BaseQuery
  type Types::StepType.connection_type, null: false
  argument :ids, [ID], required: false
  argument :location_ids, [ID], required: false

  def resolve(ids: nil, location_ids: nil)
    scope(ids, location_ids).all
  end

  protected

  def scope(ids, location_ids)
    scope = ::Step
    scope = filter_by_ids(scope, ids)
    scope = filter_by_locations(scope, location_ids)

    scope
  end

  def filter_by_ids(scope, ids)
    ids.present? ? scope.where(id: ids) : scope
  end

  def filter_by_locations(scope, ids)
    if ids.present?
      scope.joins(:location_connection_steps).where(location_connection_steps: { location_id: ids })
    else
      scope
    end
  end
end
