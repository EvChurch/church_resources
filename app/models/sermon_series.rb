# frozen_string_literal: true

class SermonSeries < ApplicationRecord
  belongs_to :sermon
  belongs_to :series

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id sermon_id series_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[sermon series]
  end
end
