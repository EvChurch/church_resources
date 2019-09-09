# frozen_string_literal: true

class Types::SeriesType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :resources, Types::ResourceType.connection_type, null: false
  field :banner_url, String, null: true
  field :foreground_url, String, null: true
  field :background_url, String, null: true

  def banner_url
    banner && polymorphic_url(banner)
  end

  def foreground_url
    foreground && polymorphic_url(foreground)
  end

  def background_url
    background && polymorphic_url(background)
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
