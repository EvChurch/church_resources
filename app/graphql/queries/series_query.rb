# frozen_string_literal: true

class Queries::SeriesQuery < Queries::BaseQuery
  type Types::SeriesType.connection_type, null: false
  argument :ids, [ID], required: false, default_value: nil
  argument :resource_type, String, required: false, default_value: nil

  def resolve(ids:, resource_type:)
    scope(ids, resource_type).all.uniq
  end

  protected

  def scope(ids, resource_type)
    scope = ::Series.joins(:resources).where.not(resources: { published_at: nil }).order('resources.published_at desc')

    scope = filter_by_ids(scope, ids)
    scope.where(resources: { type: Resource::TYPES[resource_type.to_sym] }) if resource_type.present?

    scope
  end

  def filter_by_ids(scope, ids)
    ids.present? ? scope.where(id: ids) : scope
  end
end
