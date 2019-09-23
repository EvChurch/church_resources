# frozen_string_literal: true

class CreateLocationConnectionSteps < ActiveRecord::Migration[6.0]
  def change
    create_table :location_connection_steps, id: :uuid do |t|
      t.string :form_url
      t.text :content
      t.belongs_to :step, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :location, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
