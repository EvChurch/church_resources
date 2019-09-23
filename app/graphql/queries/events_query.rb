# frozen_string_literal: true

class Queries::EventsQuery < Queries::BaseQuery
  type Types::Location::EventType.connection_type, null: false
  argument :location_ids, [ID], required: false

  def resolve(location_ids: nil)
    scope(location_ids).all
  end

  protected

  def scope(location_ids)
    return ::Location::Event if location_ids.blank?

    ::Location::Event.where(location_id: location_ids)
  end
end
