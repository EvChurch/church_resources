# frozen_string_literal: true

class Types::ResourceType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :id, ID, null: false
  field :name, String, null: false
  field :snippet, String, null: true
  field :content, String, null: true
  field :authors, [Types::AuthorType], null: false
  field :scriptures, [Types::ScriptureType], null: false
  field :connection_scriptures, [Types::Resource::Connection::ScriptureType], null: false
  field :series, [Types::SeriesType], null: false
  field :topics, [Types::TopicType], null: false
  field :banner_url, String, null: true
  field :foreground_url, String, null: true
  field :background_url, String, null: true
  field :audio_url, String, null: true
  field :video_url, String, null: true
  field :youtube_url, String, null: true
  field :published_at, GraphQL::Types::ISO8601DateTime, null: true

  def banner_url
    banner && polymorphic_url(banner)
  end

  def foreground_url
    foreground && polymorphic_url(foreground)
  end

  def background_url
    background && polymorphic_url(background)
  end

  def audio_url
    object.audio_url.presence || polymorphic_url(object.audio)
  end

  def video_url
    object.video_url.presence || polymorphic_url(object.video)
  end

  protected

  def banner
    object.banner.presence || object.series.first&.banner
  end

  def foreground
    object.foreground.presence || object.series.first&.foreground
  end

  def background
    object.background.presence || object.series.first&.background
  end
end
