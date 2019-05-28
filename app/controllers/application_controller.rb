# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery prepend: true, with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer_sign_up
    devise_parameter_sanitizer_account_update
  end

  def authenticate_admin_user!
    authenticate_user!
    redirect_to new_user_session_path unless current_user.has_role?(:admin)
  end

  private

  def devise_parameter_sanitizer_sign_up
    devise_parameter_sanitizer.permit(
      :sign_up, keys: %i[
        first_name last_name
      ]
    )
  end

  def devise_parameter_sanitizer_account_update
    devise_parameter_sanitizer.permit(
      :account_update, keys: %i[
        first_name last_name
      ]
    )
  end

  def layout_by_resource
    devise_controller? ? 'devise' : 'application'
  end
end
