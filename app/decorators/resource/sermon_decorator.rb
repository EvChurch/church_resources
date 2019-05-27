# frozen_string_literal: true

class Resource::SermonDecorator < ResourceDecorator
  def banner
    object.banner.presence || object.series.first&.banner
  end

  def background
    object.background.presence || object.series.first&.background
  end
end
