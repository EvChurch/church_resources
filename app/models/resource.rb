# frozen_string_literal: true

class Resource < ApplicationRecord
  has_one_attached :banner
  has_one_attached :foreground
  has_one_attached :background

  has_many :connection_authors, class_name: 'Resource::Connection::Author', dependent: :destroy
  has_many :authors, through: :connection_authors
  has_many :connection_scriptures, class_name: 'Resource::Connection::Scripture', dependent: :destroy
  has_many :scriptures, through: :connection_scriptures
  has_many :connection_series, class_name: 'Resource::Connection::Series', dependent: :destroy
  has_many :series, through: :connection_series
  has_many :connection_topics, class_name: 'Resource::Connection::Topics', dependent: :destroy
  has_many :topics, through: :connection_topics

  validates :name, :snippet, presence: true
end
