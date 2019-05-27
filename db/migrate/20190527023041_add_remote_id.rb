# frozen_string_literal: true

class AddRemoteId < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :remote_id, :string, index: true
    add_column :series, :remote_id, :string, index: true
    add_column :authors, :remote_id, :string, index: true
  end
end
