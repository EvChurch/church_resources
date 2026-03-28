# frozen_string_literal: true

class Types::SermonType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :audio_url, String, null: true
  field :authors, [Types::AuthorType], null: false
  field :background_url, String, null: true
  field :banner_url, String, null: true
  field :connection_scriptures, [Types::SermonScriptureType], null: false
  field :foreground_url, String, null: true
  field :id, ID, null: false
  field :name, String, null: false
  field :published_at, GraphQL::Types::ISO8601DateTime, null: true
  field :scriptures, [Types::ScriptureType], null: false
  field :series, [Types::SeriesType], null: false
  field :topics, [Types::TopicType], null: false
  field :youtube_url, String, null: true

  def banner_url
    attachment = attached_image(:banner)
    attachment && polymorphic_url(attachment)
  end

  def foreground_url
    attachment = attached_image(:foreground)
    attachment && polymorphic_url(attachment)
  end

  def background_url
    attachment = attached_image(:background)
    attachment && polymorphic_url(attachment)
  end

  def audio_url
    object.audio_url.presence || (object.audio.attached? ? polymorphic_url(object.audio) : nil)
  end

  protected

  def attached_image(name)
    attachment = object.public_send(name)
    return attachment if attachment.attached?

    series_attachment = object.series.first&.public_send(name)
    series_attachment if series_attachment&.attached?
  end
end
