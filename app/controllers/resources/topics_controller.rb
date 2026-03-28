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

    @resources = Sermon.order(published_at: :desc).joins(:topics).where(category_topics: { id: [@topic.id] })
    @resources = @resources.published.page params[:page]
  end

  def load_categories
    @categories ||= category_scope.all
  end

  def load_topic
    @topic ||= scope.friendly.find(params[:id])
  end

  def category_scope
    ::Category.joins(topics: :sermons).distinct
  end

  def scope
    ::Category::Topic
  end
end
