# frozen_string_literal: true

class ResourceDecorator < ApplicationDecorator
  decorates_association :connection_scriptures

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
    resources = Resource.published.order('RANDOM()').limit(3).left_outer_joins(:series, :authors, :topics).where.not(id: id)
    resources = resources.where(series: { id: resource.series.pluck(:id) })
    resources = resources.or(resources.where(category_topics: { id: resource.topics.pluck(:id) }))
    resources = resources.or(resources.where(authors: { id: resource.authors.pluck(:id) }))
    resources.decorate
  end
end
