# frozen_string_literal: true

class Scripture < ApplicationRecord
  validates :name, presence: true
end
