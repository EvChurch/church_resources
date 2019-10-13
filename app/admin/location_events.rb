# frozen_string_literal: true

ActiveAdmin.register Location::Event do
  menu parent: 'Locations', label: 'Events'
  permit_params :banner, :name, :content, :start_at, :end_at, :address, :elvanto_form_id, :facebook_url, :location_id

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
      f.input :facebook_url
    end
    f.actions
  end
end
