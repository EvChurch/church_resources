# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'active_admin_logged_out'
  helper ActiveAdmin::ViewHelpers

  def self.controller_path
    'active_admin/devise/sessions'
  end

  protected

  def auth_options
    super.merge(recall: 'users/sessions#new')
  end

  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  def after_sign_out_path_for(_resource_name)
    new_user_session_path
  end
end
