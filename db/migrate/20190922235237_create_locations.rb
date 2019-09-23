# frozen_string_literal: true

class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :name
      t.string :snippet
      t.text :content
      t.string :address

      t.timestamps
    end
  end
end
