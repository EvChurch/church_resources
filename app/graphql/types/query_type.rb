# frozen_string_literal: true

class Types::QueryType < Types::BaseObject
  field :authors, resolver: Queries::AuthorsQuery
  field :categories, resolver: Queries::CategoriesQuery
  field :scriptures, resolver: Queries::ScripturesQuery
  field :sermons, resolver: Queries::SermonsQuery
  field :series, resolver: Queries::SeriesQuery
  field :topics, resolver: Queries::TopicQuery
end
