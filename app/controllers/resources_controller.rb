# frozen_string_literal: true

class ResourcesController < ApplicationController
  decorates_assigned :resources, :resource

  def index
    load_resources
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
end
