# frozen_string_literal: true

class Resources::TopicsController < ApplicationController
  decorates_assigned :categories, :topic

  def index
    load_categories
  end

  def show
    load_topic
  end

  protected

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
