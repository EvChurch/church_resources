# frozen_string_literal: true

class CreateResourceConnectionAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_connection_authors, id: :uuid do |t|
      t.belongs_to :resource, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :author, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
