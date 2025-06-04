# frozen_string_literal: true

class ChurchResourcesSchema < GraphQL::Schema
  max_complexity 1000
  max_depth 10
  mutation(Types::MutationType)
  query(Types::QueryType)
end
