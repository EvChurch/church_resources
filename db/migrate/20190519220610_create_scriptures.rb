# frozen_string_literal: true

class CreateScriptures < ActiveRecord::Migration[6.0]
  def change
    create_table :scriptures, id: :uuid do |t|
      t.string :name, unique: true
      t.string :slug, unique: true

      t.timestamps
    end
  end
end
