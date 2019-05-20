# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :registerable
end
