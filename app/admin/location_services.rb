# frozen_string_literal: true

ActiveAdmin.register Location::Service do
  menu parent: 'Locations', label: 'Services'
  permit_params :start_at, :end_at, :location_id, :elvanto_form_id

  form do |f|
    f.semantic_errors
    inputs do
      f.input :start_at, as: :date_time_picker
      f.input :end_at, as: :date_time_picker
      f.input :location
      f.input :elvanto_form_id
    end
    f.actions
  end
end
