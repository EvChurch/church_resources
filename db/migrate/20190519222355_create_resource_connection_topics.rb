# frozen_string_literal: true

class CreateResourceConnectionTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_connection_topics, id: :uuid do |t|
      t.belongs_to :resource, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :topic, null: false, foreign_key: { on_delete: :cascade, to_table: :category_topics }, type: :uuid

      t.timestamps
    end
  end
end
