# frozen_string_literal: true

class ResourcesController < ApplicationController
  decorates_assigned :resources, :resource

  def index
    respond_to do |format|
      format.html do
        load_resources
      end
      format.rss do
        resource_scope = rss_resources_scope
        latest_update = resource_scope.maximum(:updated_at)

        cache_key_parts = %w[v1 rss resources]
        cache_key_parts << params[:resource_type] if params[:resource_type].present?
        cache_key_parts << latest_update.utc.to_fs(:number) if latest_update

        response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'

        cached_rss_content = Rails.cache.fetch(cache_key_parts.compact.join('/'), expires_in: 1.hour) do
          @resources = resource_scope.includes(:authors, :connection_scriptures)
          render_to_string template: 'resources/index', formats: [:rss]
        end

        render xml: cached_rss_content
      end
    end
  end

  def show
    load_resource
  end

  protected

  def load_resources
    return @resources if @resources

    @resources = scope.order(published_at: :desc).published
    if params[:resource_type].present?
      @resources = @resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    @resources = @resources.page params[:page]
  end

  def load_resource
    @resource ||= scope.friendly.find(params[:id])
  end

  def scope
    ::Resource
  end

  def rss_resources_scope
    resources = scope.order(published_at: :desc).published
    if params[:resource_type].present? && Resource::TYPES.key?(params[:resource_type].to_sym)
      resources = resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    resources
  end
end
