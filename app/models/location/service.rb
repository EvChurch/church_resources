# frozen_string_literal: true

class Location::Service < ApplicationRecord
  belongs_to :location
  validates :start_at, :end_at, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id location_id updated_at elvanto_form_id start_at end_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[location]
  end
end
