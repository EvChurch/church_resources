# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors, id: :uuid do |t|
      t.string :name, unique: true
      t.string :slug, unique: true

      t.timestamps
    end
  end
end
