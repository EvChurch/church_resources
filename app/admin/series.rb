# frozen_string_literal: true

ActiveAdmin.register Series do
  menu parent: 'Configuration'
  permit_params :name, :banner, :foreground, :background

  filter :name
  filter :slug
  filter :created_at
  filter :updated_at
  # Add filters for associations if needed, e.g.:
  # filter :resources
  # filter :connection_series

  # Filters for Active Storage attachments
  filter :banner_blob_id_not_null, as: :boolean, label: 'Has Banner'
  filter :foreground_blob_id_not_null, as: :boolean, label: 'Has Foreground'
  filter :background_blob_id_not_null, as: :boolean, label: 'Has Background'

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :banner, as: :file
      f.input :foreground, as: :file
      f.input :background, as: :file
    end
    f.actions
  end
end
