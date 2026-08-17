# frozen_string_literal: true

class Resources::AuthorsController < ApplicationController
  include PublicSermonRedirect

  def index
    redirect_to_sermon_library
  end

  def show
    redirect_to_taxonomy(scope: ::Author, segment: 'speakers')
  end
end
