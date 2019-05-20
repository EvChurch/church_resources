# frozen_string_literal: true

ActiveAdmin.register Scripture do
  menu parent: 'Configuration'
  permit_params :name
end
