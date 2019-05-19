# frozen_string_literal: true

class CreateResourceConnectionSeries < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_connection_series, id: :uuid do |t|
      t.belongs_to :resource, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :series, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
