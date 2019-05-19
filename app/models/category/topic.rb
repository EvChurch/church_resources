# frozen_string_literal: true

class Category::Topic < ApplicationRecord
  belongs_to :category
end
