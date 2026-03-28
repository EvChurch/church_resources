# frozen_string_literal: true

class Queries::CategoriesQuery < Queries::BaseQuery
  type Types::CategoryType.connection_type, null: false

  def resolve
    ::Category.joins(topics: :sermons).distinct
  end
end
