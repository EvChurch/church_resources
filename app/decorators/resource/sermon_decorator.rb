# frozen_string_literal: true

class Resource::SermonDecorator < ResourceDecorator
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
