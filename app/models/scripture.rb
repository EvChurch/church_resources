# frozen_string_literal: true

class Scripture < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :connection_scriptures, class_name: 'Resource::Connection::Scripture', dependent: :destroy
  has_many :resources, through: :connection_scriptures

  validates :name, presence: true, uniqueness: true
end
