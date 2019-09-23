# frozen_string_literal: true

class Location::Service < ApplicationRecord
  belongs_to :location
  validates :start_at, :end_at, presence: true
  validates :form_url, url: { allow_nil: true }
end
