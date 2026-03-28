# frozen_string_literal: true

class SermonAuthor < ApplicationRecord
  belongs_to :sermon
  belongs_to :author

  def self.ransackable_attributes(_auth_object = nil)
    %w[author_id created_at id sermon_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[author sermon]
  end
end
