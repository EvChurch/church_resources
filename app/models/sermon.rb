# frozen_string_literal: true

class Sermon < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_one_attached :banner
  has_one_attached :foreground
  has_one_attached :background
  has_one_attached :audio
  has_one_attached :video

  has_many :sermon_authors, dependent: :destroy
  has_many :authors, through: :sermon_authors
  has_many :sermon_scriptures, dependent: :destroy
  has_many :scriptures, through: :sermon_scriptures
  has_many :sermon_series, dependent: :destroy
  has_many :series, through: :sermon_series
  has_many :sermon_topics, dependent: :destroy
  has_many :topics, through: :sermon_topics

  accepts_nested_attributes_for :sermon_scriptures

  validates :name, presence: true

  scope :published, -> { where.not(published_at: nil) }
  scope :featured, -> { where.not(featured_at: nil) }
  scope :with_associations, -> { includes(:authors, :series, :topics, sermon_scriptures: :scripture) }

  def self.batch_publish(ids)
    where(id: ids).find_each { |r| r.update(published_at: Time.zone.now) }
  end

  def self.batch_unpublish(ids)
    where(id: ids).find_each { |r| r.update(published_at: nil) }
  end

  # Only allow these associations to be searchable by Ransack (used in ActiveAdmin filters)
  def self.ransackable_associations(_auth_object = nil)
    %w[authors scriptures series topics sermon_authors sermon_scriptures sermon_series sermon_topics]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at featured_at id name published_at slug updated_at snippet content]
  end
end
