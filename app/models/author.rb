# frozen_string_literal: true

class Author < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :connection_authors, class_name: 'Resource::Connection::Author', dependent: :destroy
  has_many :resources, through: :connection_authors

  validates :name, presence: true, uniqueness: true
end
