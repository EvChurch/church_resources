# frozen_string_literal: true

class Resources::SeriesController < ApplicationController
  include PublicSermonRedirect

  def index
    redirect_to_sermon_library
  end

  def show
    redirect_to_taxonomy(scope: ::Series, segment: 'series')
  end
end
