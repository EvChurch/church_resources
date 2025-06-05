# frozen_string_literal: true

class Category::Topic < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :connection_topics, class_name: 'Resource::Connection::Topic', dependent: :destroy
  has_many :resources, through: :connection_topics

  belongs_to :category
  validates :name, presence: true, uniqueness: true

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[resources]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[category_id created_at id name slug updated_at]
  end
end
