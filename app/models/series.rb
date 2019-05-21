# frozen_string_literal: true

class Series < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: true

  has_one_attached :banner
  has_one_attached :foreground
  has_one_attached :background
end
