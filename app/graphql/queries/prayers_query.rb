# frozen_string_literal: true

class Queries::PrayersQuery < Queries::BaseQuery
  type Types::Location::PrayerType.connection_type, null: false
  argument :location_ids, [ID], required: false

  def resolve(location_ids: nil)
    scope(location_ids).all
  end

  protected

  def scope(location_ids)
    return ::Location::Prayer if location_ids.blank?

    ::Location::Prayer.where(location_id: location_ids)
  end
end
