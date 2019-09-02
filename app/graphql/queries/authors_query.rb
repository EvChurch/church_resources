# frozen_string_literal: true

class Queries::AuthorsQuery < Queries::BaseQuery
  type Types::AuthorType.connection_type, null: false
  argument :resource_type, String, required: false

  def resolve(resource_type: nil)
    scope(resource_type).all
  end

  protected

  def scope(resource_type)
    return ::Author if resource_type.blank?

    ::Author.joins(:resources).where(resources: { type: Resource::TYPES[resource_type.to_sym] }).distinct
  end
end
