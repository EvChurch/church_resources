# frozen_string_literal: true

class ResourcesController < ApplicationController
  decorates_assigned :resources, :resource

  def index
    respond_to do |format|
      format.html { load_resources }
      format.rss { render_rss_feed }
    end
  end

  def show
    load_resource
  end

  protected

  def load_resources
    return @resources if @resources

    @resources = scope.order(published_at: :desc).published
    @resources = @resources.page params[:page]
  end

  def load_resource
    @resource ||= scope.friendly.find(params[:id])
  end

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
      @resources = resource_scope.includes(:authors, :sermon_scriptures)
      render_to_string template: 'resources/index', formats: [:rss]
    end

    render xml: cached_rss_content
  end

  def rss_resources_scope
    scope.order(published_at: :desc).published
  end
end
