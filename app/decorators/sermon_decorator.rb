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
    sermons = related_sermon_scope.where(series: { id: object.series.ids })
    sermons = add_related_conditions(sermons)
    sermons.includes(:authors, :series, sermon_scriptures: :scripture).decorate
  end

  def description
    author_names = authors.map(&:name).join(', ')
    scripture_names = sermon_scriptures.map(&:name).join(', ')
    display_published_at = published_at.strftime('%b %d, %Y')

    [author_names, scripture_names, display_published_at].compact_blank.join(' | ')
  end

  def author_names
    object.authors.map(&:name).join(', ')
  end

  def add_related_conditions(sermons)
    { category_topics: object.topics, authors: object.authors, scriptures: object.scriptures }.each do |table, assoc|
      ids = assoc.map(&:id)
      sermons = sermons.or(sermons.where(table => { id: ids })) if ids.any?
    end
    sermons
  end

  def related_sermon_scope
    Sermon.published
          .order('RANDOM()')
          .limit(3)
          .left_outer_joins(:series, :authors, :topics, :scriptures)
          .where.not(id: id)
  end
end
