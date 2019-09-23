# frozen_string_literal: true

class Location::Connection::Step < ApplicationRecord
  belongs_to :step, class_name: '::Step'
  belongs_to :location, class_name: '::Location'
  validates :elvanto_form_id, presence: true
end
