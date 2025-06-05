# frozen_string_literal: true

ActiveAdmin.register Category do
  menu parent: 'Configuration'
  permit_params :name

  filter :name
  filter :topics
  filter :created_at
  filter :updated_at
end
