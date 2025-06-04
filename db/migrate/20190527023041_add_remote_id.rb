# frozen_string_literal: true

class AddRemoteId < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :remote_id, :string
    add_index :resources, :remote_id
    add_column :series, :remote_id, :string
    add_index :series, :remote_id
    add_column :authors, :remote_id, :string
    add_index :authors, :remote_id
  end
end
