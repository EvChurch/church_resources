# frozen_string_literal: true

class ChurchResourcesSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
end
