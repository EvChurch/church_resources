# frozen_string_literal: true

class Location::Service < ApplicationRecord
  belongs_to :location
  validates :start_at, :end_at, presence: true
end
