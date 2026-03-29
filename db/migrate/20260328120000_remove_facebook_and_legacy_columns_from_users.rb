# frozen_string_literal: true

class RemoveFacebookAndLegacyColumnsFromUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.remove :facebook_token, type: :string
      t.remove :facebook_remote_id, type: :string
      t.remove :avatar_url, type: :string
      t.remove :name, type: :string
    end
  end
end
