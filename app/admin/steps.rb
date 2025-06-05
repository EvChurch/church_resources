# frozen_string_literal: true

ActiveAdmin.register Step do
  permit_params :name, :content, :banner
  config.sort_order = 'position_asc'

  scope :featured
  scope :all, default: true

  filter :name
  filter :created_at
  filter :updated_at

  batch_action :feature do |ids|
    batch_action_collection.find(ids).each do |step|
      step.update(featured_at: Time.zone.now)
    end
    redirect_to collection_path, alert: 'The step(s) have been featured'
  end

  batch_action :unfeature do |ids|
    batch_action_collection.find(ids).each do |event|
      event.update(featured_at: nil)
    end
    redirect_to collection_path, warning: 'The step(s) have been unfeatured'
  end

  index do
    selectable_column
    column do |post|
      [
        link_to(icon('chevron-up', 'font-awesome'), move_higher_admin_step_path(post)),
        link_to(icon('chevron-down', 'font-awesome'), move_lower_admin_step_path(post))
      ].join(' ').html_safe
    end
    column :position
    column :name
    column :featured_at
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
      f.input :content, as: :text
    end
    f.actions
  end
end
