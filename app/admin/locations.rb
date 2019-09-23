# frozen_string_literal: true

ActiveAdmin.register Location do
  permit_params :name, :snippet, :content, :address, :banner

  filter :name
  filter :snippet
  filter :content
  filter :address

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :banner, as: :file
      f.input :snippet
      f.input :content, as: :trix
      f.input :address
    end
    f.actions
  end
end
