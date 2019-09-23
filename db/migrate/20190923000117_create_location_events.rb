# frozen_string_literal: true

class CreateLocationEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :location_events, id: :uuid do |t|
      t.timestamp :start_at
      t.timestamp :end_at
      t.string :name
      t.string :snippet
      t.text :content
      t.string :address
      t.string :elvanto_form_id
      t.string :facebook_url
      t.belongs_to :location, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
