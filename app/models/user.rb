# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :registerable

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[roles]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at email encrypted_password first_name id last_name locked_at
       reset_password_sent_at reset_password_token sign_in_count updated_at]
  end
end
