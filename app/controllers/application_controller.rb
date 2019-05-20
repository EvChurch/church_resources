# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer_sign_up
    devise_parameter_sanitizer_account_update
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
end
