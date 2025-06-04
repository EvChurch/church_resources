# frozen_string_literal: true

class Types::SeriesType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :background_url, String, null: true
  field :banner_url, String, null: true
  field :foreground_url, String, null: true
  field :id, ID, null: false
  field :name, String, null: false
  field :resources, Types::ResourceType.connection_type, null: false

  def banner_url
    object.banner.presence && polymorphic_url(
      object.banner.variant(
        convert: 'jpg', saver: { quality: 80 }, strip: true, resize_to_limit: [1920, 1080]
      )
    )
  end

  def foreground_url
    object.foreground.presence && polymorphic_url(object.foreground)
  end

  def background_url
    object.background.presence && polymorphic_url(object.background)
  end
end
