# frozen_string_literal: true

class Location::Event < ApplicationRecord
  belongs_to :location
  has_one_attached :banner
  validates :start_at, :end_at, :name, :content, :address, presence: true
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
  validates :registration_url, :facebook_url, url: { allow_blank: true }
  scope :upcoming, -> { where(end_at: Time.zone.today..).order(:start_at) }
  scope :featured, -> { upcoming.where.not(featured_at: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id location_id updated_at elvanto_form_id name content address start_at end_at featured_at
       facebook_url registration_url]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[location banner_attachment banner_blob]
  end
end
