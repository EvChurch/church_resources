# frozen_string_literal: true

class AddContentToConnectionScriptures < ActiveRecord::Migration[6.0]
  def change
    add_column :resource_connection_scriptures, :content, :text
  end
end
