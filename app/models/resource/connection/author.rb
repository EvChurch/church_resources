# frozen_string_literal: true

class Resource::Connection::Author < ApplicationRecord
  belongs_to :resource
  belongs_to :author

  def self.ransackable_attributes(auth_object = nil)
    %w[author_id created_at id resource_id updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[author resource]
  end
end
