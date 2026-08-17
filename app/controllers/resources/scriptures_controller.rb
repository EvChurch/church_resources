# frozen_string_literal: true

class Resources::ScripturesController < ApplicationController
  include PublicSermonRedirect

  def index
    redirect_to_sermon_library
  end

  def show
    redirect_to_taxonomy(scope: ::Scripture, segment: 'scriptures')
  end
end
