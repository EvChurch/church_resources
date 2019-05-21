# frozen_string_literal: true

ActiveAdmin.register Series do
  menu parent: 'Configuration'
  permit_params :name, :banner, :foreground, :background

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
