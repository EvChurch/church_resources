# frozen_string_literal: true

class CreateLocationPrayers < ActiveRecord::Migration[6.0]
  def change
    create_table :location_prayers, id: :uuid do |t|
      t.string :name
      t.string :snippet
      t.text :content
      t.belongs_to :location, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
