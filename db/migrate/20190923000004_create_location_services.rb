# frozen_string_literal: true

class CreateLocationServices < ActiveRecord::Migration[6.0]
  def change
    create_table :location_services, id: :uuid do |t|
      t.timestamp :start_at
      t.timestamp :end_at
      t.belongs_to :location, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :elvanto_form_id

      t.timestamps
    end
  end
end
