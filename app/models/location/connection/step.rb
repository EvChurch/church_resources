# frozen_string_literal: true

class Location::Connection::Step < ApplicationRecord
  belongs_to :step, class_name: '::Step'
  belongs_to :location, class_name: '::Location'

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id location_id step_id updated_at elvanto_form_id content mail_chimp_user_id mail_chimp_audience_id
       fluro_form_url]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[location step]
  end
end
