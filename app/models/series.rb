# frozen_string_literal: true

class Series < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: true
end
