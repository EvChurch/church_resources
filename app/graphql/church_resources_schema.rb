# frozen_string_literal: true

class ChurchResourcesSchema < GraphQL::Schema
  max_complexity 1000
  max_depth 13
  default_max_page_size 100
  query(Types::QueryType)
end
