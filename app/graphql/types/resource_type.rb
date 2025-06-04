# frozen_string_literal: true

class Types::ResourceType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :audio_url, String, null: true
  field :authors, [Types::AuthorType], null: false
  field :background_url, String, null: true
  field :banner_url, String, null: true
  field :connect_group_notes, String, null: true
  field :connection_scriptures, [Types::Resource::Connection::ScriptureType], null: false
  field :content, String, null: true
  field :foreground_url, String, null: true
  field :id, ID, null: false
  field :name, String, null: false
  field :published_at, GraphQL::Types::ISO8601DateTime, null: true
  field :scriptures, [Types::ScriptureType], null: false
  field :series, [Types::SeriesType], null: false
  field :sermon_notes, String, null: true
  field :snippet, String, null: true
  field :topics, [Types::TopicType], null: false
  field :video_url, String, null: true
  field :youtube_url, String, null: true

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
