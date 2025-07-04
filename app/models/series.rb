# frozen_string_literal: true

class Series < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :connection_series, class_name: 'Resource::Connection::Series', dependent: :destroy
  has_many :resources, through: :connection_series

  validates :name, presence: true, uniqueness: true

  has_one_attached :banner
  has_one_attached :foreground
  has_one_attached :background

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[resources connection_series banner_attachment banner_blob foreground_attachment foreground_blob
       background_attachment background_blob]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name slug updated_at banner foreground background]
  end
end
