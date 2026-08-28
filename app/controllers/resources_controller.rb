# frozen_string_literal: true

class ResourcesController < ApplicationController
  include PublicSermonRedirect

  def index
    respond_to do |format|
      format.html { redirect_to_sermon_library }
      format.rss do
        redirect_to 'https://www.ev.church/sermons/feed.xml', allow_other_host: true, status: :moved_permanently
      end
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to_sermon_library }
    end
  end

  def passage
    query = { search: params[:search], version: params[:version] }.compact_blank.to_query
    target = ['https://www.biblegateway.com/passage/', query.presence].compact.join('?')

    redirect_to target, allow_other_host: true, status: :moved_permanently
  end

  protected

  def scope
    ::Sermon
  end

  def render_rss_feed
    resource_scope = rss_resources_scope
    latest_update = resource_scope.maximum(:updated_at)

    cache_key_parts = %w[v1 rss resources]
    cache_key_parts << latest_update.utc.to_fs(:number) if latest_update

    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'

    cached_rss_content = Rails.cache.fetch(cache_key_parts.compact.join('/'), expires_in: 1.day) do
      @resources = resource_scope.includes(:authors, sermon_scriptures: :scripture)
      render_to_string template: 'resources/index', formats: [:rss]
    end

    render xml: cached_rss_content
  end

  def rss_resources_scope
    scope.order(published_at: :desc).published
  end
end
