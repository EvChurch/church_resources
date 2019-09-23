# frozen_string_literal: true

ActiveAdmin.register Step do
  permit_params :name, :snippet, :content, :banner

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :banner, as: :file
      f.input :snippet
      f.input :content
    end
    f.actions
  end
end
