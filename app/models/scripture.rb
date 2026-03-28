# frozen_string_literal: true

class Scripture < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :sermon_scriptures, dependent: :destroy
  has_many :sermons, through: :sermon_scriptures

  validates :name, presence: true, uniqueness: true

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[sermons sermon_scriptures]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name slug updated_at]
  end
end
