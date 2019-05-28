# frozen_string_literal: true

class AddRangeToResourceConnectionScriptures < ActiveRecord::Migration[6.0]
  def change
    add_column :resource_connection_scriptures, :range, :string
  end
end
