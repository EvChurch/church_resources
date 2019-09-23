# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :prayers, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :location_connection_steps, dependent: :destroy, class_name: 'Location::Connection::Step'
  has_one_attached :banner
  validates :name, :snippet, :content, :address, presence: true
  validates :banner,
            attached: true,
            aspect_ratio: :is_16_9,
            content_type: %r{\Aimage/.*\z},
            dimension: {
              width: { in: 0..1920 },
              height: { in: 0..1080 },
              message: '1920x1080 max resolution'
            },
            size: { less_than: 500.kilobytes, message: '500KB max size' }
end
