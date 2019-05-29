# frozen_string_literal: true

class ResourcesController < ApplicationController
  decorates_assigned :resources, :resource

  def index
    respond_to do |format|
      format.html do
        load_resources
      end
      format.rss do
        load_all_resources
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

  def load_all_resources
    return @resources if @resources

    @resources = scope.order(published_at: :desc).published
    if params[:resource_type].present?
      @resources = @resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    @resources
  end

  def load_resource
    @resource ||= scope.friendly.find(params[:id])
  end

  def scope
    ::Resource
  end
end
