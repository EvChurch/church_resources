# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    return unless valid_email?

    user = User.from_facebook_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect user, event: :authentication if user.persisted?
  end

  def failure
    redirect_to new_user_session_path
  end

  private

  def valid_email?
    if request.env['omniauth.auth'].info.email.blank?
      redirect_to '/users/auth/facebook?auth_type=rerequest&scope=email'
      false
    else
      true
    end
  end
end
