# frozen_string_literal: true

class CreateResourceConnectionScriptures < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_connection_scriptures, id: :uuid do |t|
      t.belongs_to :resource, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :scripture, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
