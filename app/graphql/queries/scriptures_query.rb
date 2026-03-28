# frozen_string_literal: true

class Queries::ScripturesQuery < Queries::BaseQuery
  type Types::ScriptureType.connection_type, null: false

  def resolve
    ::Scripture.joins(:sermons).distinct
  end
end
