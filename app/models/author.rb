# frozen_string_literal: true

class Author < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :connection_authors, class_name: 'Resource::Connection::Author', dependent: :destroy
  has_many :resources, through: :connection_authors

  validates :name, presence: true, uniqueness: true

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[resources connection_authors]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name remote_id slug updated_at]
  end
end
