# frozen_string_literal: true

ActiveAdmin.register Category::Topic do
  menu parent: 'Configuration', label: 'Topics'
  permit_params :name, :category_id
end
