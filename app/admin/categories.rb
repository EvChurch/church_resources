# frozen_string_literal: true

ActiveAdmin.register Category do
  menu parent: 'Configuration'
  permit_params :name
end
