# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :registerable

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[roles]
  end
end
