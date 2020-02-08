# frozen_string_literal: true

ActiveAdmin.register Location::Event do
  menu parent: 'Locations', label: 'Events'
  permit_params :banner, :name, :content, :start_at, :end_at, :address, :elvanto_form_id, :facebook_url, :location_id,
                :registration_url

  scope :upcoming, default: true
  scope :featured
  scope :all

  batch_action :feature do |ids|
    batch_action_collection.find(ids).each do |event|
      event.update(featured_at: Time.zone.now)
    end
    redirect_to collection_path, success: 'The event(s) have been featured'
  end

  batch_action :unfeature do |ids|
    batch_action_collection.find(ids).each do |event|
      event.update(featured_at: nil)
    end
    redirect_to collection_path, warning: 'The event(s) have been unfeatured'
  end

  index do
    selectable_column
    column :name
    column :location
    column :address
    column :start_at
    column :end_at
    column :featured_at
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :banner, as: :file
      f.input :content, as: :trix
      f.input :location
      f.input :start_at, as: :date_time_picker
      f.input :end_at, as: :date_time_picker
      f.input :address
      f.input :elvanto_form_id
      f.input :registration_url
      f.input :facebook_url
    end
    f.actions
  end
end
