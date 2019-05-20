# frozen_string_literal: true

class Resources::ScripturesController < ApplicationController
  decorates_assigned :scripture

  def index
    load_scriptures
  end

  def show
    load_scripture
  end

  protected

  def load_scriptures
    @scriptures ||= alphabetized_scripture
  end

  def load_scripture
    @scripture ||= scope.friendly.find(params[:id])
  end

  def alphabetized_scripture
    hash = {}
    scope.all.decorate.each do |scripture|
      letter = scripture.name[/[A-Za-z]/]
      hash[letter] ||= []
      hash[letter].push(scripture)
    end
    hash.sort.in_groups(3, false).map(&:to_h)
  end

  def scope
    ::Scripture
  end
end
