# frozen_string_literal: true

class Queries::AuthorsQuery < Queries::BaseQuery
  type Types::AuthorType.connection_type, null: false

  def resolve
    ::Author.joins(:sermons).distinct
  end
end
