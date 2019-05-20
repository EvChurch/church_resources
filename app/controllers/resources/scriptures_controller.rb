# frozen_string_literal: true

class Resources::ScripturesController < ApplicationController
  decorates_assigned :scripture, :resources

  def index
    load_scriptures
  end

  def show
    load_scripture
    load_resources
  end

  protected

  def load_resources
    return @resources if @resources

    @resources = Resource.where(scriptures: [@scripture])
    if params[:resource_type].present?
      @resources = @resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    @resources = @resources.page params[:page]
  end

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
