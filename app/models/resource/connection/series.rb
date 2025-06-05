# frozen_string_literal: true

class Resource::Connection::Series < ApplicationRecord
  belongs_to :resource
  belongs_to :series

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id resource_id series_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[resource series] # Added common associations, can be emptied if not needed for search
  end
end
