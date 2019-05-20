# frozen_string_literal: true

ActiveAdmin.register Series do
  menu parent: 'Configuration'
  permit_params :name
end
