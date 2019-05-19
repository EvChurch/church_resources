# frozen_string_literal: true

class CreateCategoryTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :category_topics, id: :uuid do |t|
      t.string :name
      t.belongs_to :category, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
