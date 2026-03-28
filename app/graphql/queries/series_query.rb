# frozen_string_literal: true

class Queries::SeriesQuery < Queries::BaseQuery
  type Types::SeriesType.connection_type, null: false
  argument :ids, [ID], required: false, default_value: nil

  def resolve(ids:)
    scope(ids).all.uniq
  end

  protected

  def scope(ids)
    scope = ::Series.joins(:sermons).merge(Sermon.published).order('sermons.published_at desc')
    ids.present? ? scope.where(id: ids) : scope
  end
end
