# frozen_string_literal: true

class Category::Topic < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category
  validates :name, presence: true, uniqueness: true
end
