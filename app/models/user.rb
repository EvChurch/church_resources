# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :registerable
end
