# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :registerable, :omniauthable, omniauth_providers: [:facebook]

  class << self
    def from_facebook_omniauth(params)
      user = find_user_from_facebook(params)
      user.password = Devise.friendly_token.first(8) unless user.persisted?
      user.update(
        email: params.info.email,
        facebook_token: params.credentials.token,
        name: params.info.name,
        facebook_remote_id: params.uid,
        avatar_url: params.info.image
      )
      user
    end

    private

    def find_user_from_facebook(params)
      user = find_by(facebook_remote_id: params.uid)
      user ||= find_by(email: params.info.email)
      user ||= new
      user
    end
  end
end
