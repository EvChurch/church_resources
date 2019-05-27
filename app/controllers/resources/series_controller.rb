# frozen_string_literal: true

class Resources::SeriesController < ApplicationController
  decorates_assigned :series, :resources

  def index
    load_series_index
  end

  def show
    load_series
    load_resources
  end

  protected

  def load_resources
    return @resources if @resources

    @resources = Resource.order(:created_at).joins(:series).where(series: { id: [@series.id] })
    if params[:resource_type].present?
      @resources = @resources.where(type: Resource::TYPES[params[:resource_type].to_sym])
    end
    @resources = @resources.published.page params[:page]
  end

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
    return ::Series unless params[:resource_type]

    ::Series.joins(:resources).where(resources: { type: Resource::TYPES[params[:resource_type].to_sym] }).distinct
  end
end
