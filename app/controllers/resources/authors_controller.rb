# frozen_string_literal: true

class Resources::AuthorsController < ApplicationController
  decorates_assigned :author

  def index
    load_authors
  end

  def show
    load_author
  end

  protected

  def load_authors
    @authors ||= alphabetized_authors
  end

  def load_author
    @author ||= scope.friendly.find(params[:id])
  end

  def alphabetized_authors
    hash = {}
    scope.all.decorate.each do |author|
      letter = author.name[/[A-Za-z]/]
      hash[letter] ||= []
      hash[letter].push(author)
    end
    hash.sort.in_groups(3, false).map(&:to_h)
  end

  def scope
    ::Author
  end
end
