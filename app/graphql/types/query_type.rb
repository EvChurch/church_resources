# frozen_string_literal: true

class Types::QueryType < Types::BaseObject
  field :authors, resolver: Queries::AuthorsQuery
  field :categories, resolver: Queries::CategoriesQuery
  field :events, resolver: Queries::EventsQuery
  field :locations, resolver: Queries::LocationsQuery
  field :prayers, resolver: Queries::PrayersQuery
  field :resources, resolver: Queries::ResourcesQuery
  field :scriptures, resolver: Queries::ScripturesQuery
  field :series, resolver: Queries::SeriesQuery
  field :steps, resolver: Queries::StepsQuery
  field :topics, resolver: Queries::TopicQuery
end
