# frozen_string_literal: true

class Queries::ResourcesQuery < Queries::BaseQuery
  type Types::ResourceType.connection_type, null: false
  argument :author_ids, [ID], required: false, default_value: nil
  argument :category_ids, [ID], required: false, default_value: nil
  argument :scripture_ids, [ID], required: false, default_value: nil
  argument :series_ids, [ID], required: false, default_value: nil
  argument :topic_ids, [ID], required: false, default_value: nil
  argument :resource_type, String, required: false, default_value: nil

  def resolve(author_ids:, category_ids:, scripture_ids:, series_ids:, topic_ids:, resource_type:)
    scope(author_ids, category_ids, scripture_ids, series_ids, topic_ids, resource_type).all
  end

  protected

  def scope(author_ids, category_ids, scripture_ids, series_ids, topic_ids, resource_type)
    scope = ::Resource.published.order(published_at: :desc)

    scope = filter_by_authors(scope, author_ids)
    scope = filter_by_categories(scope, category_ids)
    scope = filter_by_scriptures(scope, scripture_ids)
    scope = filter_by_series(scope, series_ids)
    scope = filter_by_topics(scope, topic_ids)
    scope = scope.where(type: Resource::TYPES[resource_type.to_sym]) if resource_type.present?

    scope
  end

  def filter_by_authors(scope, ids)
    ids.present? ? scope.joins(:authors).where(authors: { id: ids }) : scope
  end

  def filter_by_categories(scope, ids)
    ids.present? ? scope.joins(:categories).where(categories: { id: ids }) : scope
  end

  def filter_by_scriptures(scope, ids)
    ids.present? ? scope.joins(:scriptures).where(scriptures: { id: ids }) : scope
  end

  def filter_by_series(scope, ids)
    ids.present? ? scope.joins(:series).where(series: { id: ids }) : scope
  end

  def filter_by_topics(scope, ids)
    ids.present? ? scope.joins(:topics).where(topics: { id: ids }) : scope
  end
end
