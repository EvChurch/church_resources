# frozen_string_literal: true

class Location::Event < ApplicationRecord
  belongs_to :location
  has_one_attached :banner
  validates :start_at, :end_at, :name, :snippet, :content, :address, presence: true
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
  validates :facebook_url, url: { allow_blank: true }
  scope :upcoming, -> { where('end_at >= ?', Time.zone.today).order(:start_at) }
end
