# frozen_string_literal: true

class ResourceDecorator < ApplicationDecorator
  decorates_association :connection_scriptures
  decorates_association :authors

  def action
    'view'
  end

  def type_title
    type_param.titleize
  end

  def type_param
    type.demodulize.downcase
  end

  def related
    resources = related_resource_scope
    resources = resources.where(series: { id: resource.series.pluck(:id) })
    resources = resources.or(resources.where(category_topics: { id: resource.topics.pluck(:id) }))
    resources = resources.or(resources.where(authors: { id: resource.authors.pluck(:id) }))
    resources = resources.or(resources.where(scriptures: { id: resource.scriptures.pluck(:id) }))
    resources.decorate
  end

  def description
    return snippet if snippet.present?

    author_names = authors.map(&:name).join(', ')
    scripture_names = connection_scriptures.map(&:name).join(', ')
    display_published_at = published_at.strftime('%b %d, %Y')

    [author_names, scripture_names, display_published_at].select(&:present?).join(' | ')
  end

  def author_names
    resource.authors.map(&:name).join(', ')
  end

  def related_resource_scope
    Resource.published
            .order('RANDOM()')
            .limit(3)
            .left_outer_joins(:series, :authors, :topics, :scriptures)
            .where.not(id: id)
  end
end
