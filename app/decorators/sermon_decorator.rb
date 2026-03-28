# frozen_string_literal: true

class SermonDecorator < ApplicationDecorator
  decorates_association :sermon_scriptures
  decorates_association :authors

  def action
    'view'
  end

  def type_title
    'Sermon'
  end

  def type_param
    'sermon'
  end

  def banner
    object.banner.presence || object.series.first&.banner
  end

  def foreground
    object.foreground.presence || object.series.first&.foreground
  end

  def background
    object.background.presence || object.series.first&.background
  end

  def related
    sermons = related_sermon_scope
    sermons = sermons.where(series: { id: object.series.pluck(:id) })
    sermons = sermons.or(sermons.where(category_topics: { id: object.topics.pluck(:id) }))
    sermons = sermons.or(sermons.where(authors: { id: object.authors.pluck(:id) }))
    sermons = sermons.or(sermons.where(scriptures: { id: object.scriptures.pluck(:id) }))
    sermons.decorate
  end

  def description
    return snippet if snippet.present?

    author_names = authors.map(&:name).join(', ')
    scripture_names = sermon_scriptures.map(&:name).join(', ')
    display_published_at = published_at.strftime('%b %d, %Y')

    [author_names, scripture_names, display_published_at].compact_blank.join(' | ')
  end

  def author_names
    object.authors.map(&:name).join(', ')
  end

  def related_sermon_scope
    Sermon.published
          .order('RANDOM()')
          .limit(3)
          .left_outer_joins(:series, :authors, :topics, :scriptures)
          .where.not(id: id)
  end
end
