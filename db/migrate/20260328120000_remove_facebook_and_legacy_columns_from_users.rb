# frozen_string_literal: true

class RemoveFacebookAndLegacyColumnsFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :facebook_token, :string
    remove_column :users, :facebook_remote_id, :string
    remove_column :users, :avatar_url, :string
    remove_column :users, :name, :string
  end
end
