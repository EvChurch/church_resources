# frozen_string_literal: true

class Resources::TopicsController < ApplicationController
  include PublicSermonRedirect

  def index
    redirect_to_sermon_library
  end

  def show
    redirect_to_taxonomy(scope: ::Category::Topic, segment: 'topics')
  end
end
