# frozen_string_literal: true

class Resources::SeriesController < ApplicationController
  decorates_assigned :series

  def index
    load_series_index
  end

  def show
    load_series
  end

  protected

  def load_series_index
    @series_index ||= alphabetized_series
  end

  def load_series
    @series ||= scope.friendly.find(params[:id])
  end

  def alphabetized_series
    hash = {}
    scope.all.decorate.each do |series|
      letter = series.name[/[A-Za-z]/]
      hash[letter] ||= []
      hash[letter].push(series)
    end
    hash.sort.in_groups(3, false).map(&:to_h)
  end

  def scope
    ::Series
  end
end
