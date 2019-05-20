# frozen_string_literal: true

ActiveAdmin.register Author do
  menu parent: 'Configuration'
  permit_params :name
end
