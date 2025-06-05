# frozen_string_literal: true

class Resource::Connection::Topic < ApplicationRecord
  belongs_to :resource
  belongs_to :topic, class_name: 'Category::Topic'

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id resource_id topic_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[resource topic]
  end
end
