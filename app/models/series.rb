# frozen_string_literal: true

class Series < ApplicationRecord
  validates :name, presence: true
end
