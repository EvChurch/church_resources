# frozen_string_literal: true

ActiveAdmin.register Step do
  permit_params :name, :content, :banner
  config.sort_order = 'position_asc'

  filter :name
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column do |post|
      [
        link_to(fa_icon('chevron-up'), move_higher_admin_step_path(post)),
        link_to(fa_icon('chevron-down'), move_lower_admin_step_path(post))
      ].join(' ').html_safe
    end
    column :position
    column :name
    actions
  end

  member_action :move_higher, method: :get do
    flash[:notice] = "#{resource.name} moved higher"
    resource.move_higher
    redirect_to action: :index
  end

  member_action :move_lower, method: :get do
    flash[:notice] = "#{resource.name} moved lower"
    resource.move_lower
    redirect_to action: :index
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :name
      f.input :banner, as: :file
      f.input :content, as: :trix
    end
    f.actions
  end
end
