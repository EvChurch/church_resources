# frozen_string_literal: true

class Types::SeriesType < Types::BaseObject
  include Rails.application.routes.url_helpers

  field :id, ID, null: false
  field :name, String, null: false
  field :resources, Types::ResourceType.connection_type, null: false
  field :banner_url, String, null: true
  field :foreground_url, String, null: true
  field :background_url, String, null: true

  def banner_url
    object.banner && polymorphic_url(object.banner)
  end

  def foreground_url
    object.foreground && polymorphic_url(object.foreground)
  end

  def background_url
    object.background && polymorphic_url(object.background)
  end
end
