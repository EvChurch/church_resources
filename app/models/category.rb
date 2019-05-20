# frozen_string_literal: true

class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :topics, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
