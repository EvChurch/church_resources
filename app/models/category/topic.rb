# frozen_string_literal: true

class Category::Topic < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :connection_topics, class_name: 'Resource::Connection::Topic', dependent: :destroy
  has_many :resources, through: :connection_topics

  belongs_to :category
  validates :name, presence: true, uniqueness: true
end
