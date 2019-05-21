# frozen_string_literal: true

class Resource::SermonDecorator < ResourceDecorator
  def banner
    object.banner.presence || object.series.first&.banner
  end
end
