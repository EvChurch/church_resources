# frozen_string_literal: true

class SermonTopic < ApplicationRecord
  belongs_to :sermon
  belongs_to :topic, class_name: 'Category::Topic'

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id sermon_id topic_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[sermon topic]
  end
end
