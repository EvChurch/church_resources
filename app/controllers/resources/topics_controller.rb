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

    @resources = Resource.order(:created_at).joins(:topics).where(category_topics: { id: [@topic.id] })
    if params[:resource_type].present?
      @resources = @resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    @resources = @resources.published.page params[:page]
  end

  def load_categories
    @categories ||= category_scope.all
  end

  def load_topic
    @topic ||= scope.friendly.find(params[:id])
  end

  def category_scope
    return ::Category unless params[:resource_type]

    ::Category.joins(topics: :resources).where(
      resources: { type: Resource::TYPES[params[:resource_type].to_sym] }
    ).distinct
  end

  def scope
    return ::Category::Topic unless params[:resource_type]

    ::Category::Topic.joins(:resources).where(
      resources: { type: Resource::TYPES[params[:resource_type].to_sym] }
    ).distinct
  end
end
