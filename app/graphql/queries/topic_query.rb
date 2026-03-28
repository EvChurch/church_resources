# frozen_string_literal: true

class Queries::TopicQuery < Queries::BaseQuery
  type Types::TopicType.connection_type, null: false

  def resolve
    ::Category::Topic.joins(:sermons).distinct
  end
end
