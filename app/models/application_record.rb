# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Default: no ransackable associations unless overridden in the model
  def self.ransackable_associations(*)
    []
  end
end
