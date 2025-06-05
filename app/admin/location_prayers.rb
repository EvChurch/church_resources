# frozen_string_literal: true

ActiveAdmin.register Location::Prayer do
  menu parent: 'Locations', label: 'Prayers'
  permit_params :banner, :name, :snippet, :content, :location_id

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :banner, as: :file
      f.input :snippet
      f.input :content, as: :text
      f.input :location
    end
    f.actions
  end
end
