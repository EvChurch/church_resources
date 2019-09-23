# frozen_string_literal: true

ActiveAdmin.register Location::Connection::Step do
  menu parent: 'Locations', label: 'Steps'
  permit_params :content, :elvanto_form_id, :location_id, :step_id

  form do |f|
    f.semantic_errors
    inputs do
      f.input :location
      f.input :step
      f.input :content, as: :trix
      f.input :elvanto_form_id
    end
    f.actions
  end
end
