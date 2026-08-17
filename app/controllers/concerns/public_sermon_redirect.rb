# frozen_string_literal: true

module PublicSermonRedirect
  extend ActiveSupport::Concern

  SERMON_LIBRARY_URL = 'https://www.ev.church/sermons'

  private

  def redirect_to_sermon_library(path = nil)
    target = [SERMON_LIBRARY_URL, path].compact.join('/')

    redirect_to target, allow_other_host: true, status: :moved_permanently
  end

  def redirect_to_taxonomy(scope:, segment:)
    record = scope.friendly.find(params[:id])
    slug = church_web_slug(record.name)

    return redirect_to_sermon_library if slug.blank?

    redirect_to_sermon_library("#{segment}/#{slug}")
  rescue ActiveRecord::RecordNotFound
    redirect_to_sermon_library
  end

  def church_web_slug(value)
    value.to_s.downcase.gsub(/[^a-z0-9]+/, '-').delete_prefix('-').delete_suffix('-')
  end
end
