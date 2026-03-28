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
    series_ids = object.series.map(&:id)
    topic_ids = object.topics.map(&:id)
    author_ids = object.authors.map(&:id)
    scripture_ids = object.scriptures.map(&:id)

    sermons = related_sermon_scope
    sermons = sermons.where(series: { id: series_ids })
    sermons = sermons.or(sermons.where(category_topics: { id: topic_ids })) if topic_ids.any?
    sermons = sermons.or(sermons.where(authors: { id: author_ids })) if author_ids.any?
    sermons = sermons.or(sermons.where(scriptures: { id: scripture_ids })) if scripture_ids.any?
    sermons.includes(:authors, :series, sermon_scriptures: :scripture).decorate
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
