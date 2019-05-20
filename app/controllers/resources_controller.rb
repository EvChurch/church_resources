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
    @resources ||= scope.all
  end

  def load_resource
    @resource ||= scope.friendly.find(params[:id])
  end

  def scope
    ::Resource
  end
end
