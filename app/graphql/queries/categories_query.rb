# frozen_string_literal: true

class Queries::CategoriesQuery < Queries::BaseQuery
  type Types::CategoryType.connection_type, null: false
  argument :resource_type, String, required: false

  def resolve(resource_type: nil)
    scope(resource_type).all
  end

  protected

  def scope(resource_type)
    return ::Category if resource_type.blank?

    ::Category.joins(:resources).where(resources: { type: Resource::TYPES[resource_type.to_sym] }).distinct
  end
end
