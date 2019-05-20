# frozen_string_literal: true

class Resources::TopicsController < ApplicationController
  decorates_assigned :categories, :topic, :resources

  def index
    load_categories
  end

  def show
    load_topic
    load_resources
  end

  protected

  def load_resources
    return @resources if @resources

    @resources = Resource.where(topics: [@topic])
    if params[:resource_type].present?
      @resources = @resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    @resources = @resources.page params[:page]
  end

  def load_categories
    @categories ||= Category.includes(:topics).all
  end

  def load_topic
    @topic ||= scope.friendly.find(params[:id])
  end

  def scope
    ::Category::Topic
  end
end
