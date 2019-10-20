# frozen_string_literal: true

class AddFbToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :facebook_token, :string
    add_column :users, :name, :string
    add_column :users, :facebook_remote_id, :string
    add_column :users, :avatar_url, :string
  end
end
