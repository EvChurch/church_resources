# frozen_string_literal: true

class RemoveRemoteIdFromAuthorsAndSeries < ActiveRecord::Migration[7.2]
  def change
    remove_column :authors, :remote_id, :string
    remove_column :series, :remote_id, :string
  end
end
