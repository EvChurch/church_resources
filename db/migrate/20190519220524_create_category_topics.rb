# frozen_string_literal: true

class CreateCategoryTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :category_topics, id: :uuid do |t|
      t.string :name, unique: true
      t.belongs_to :category, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :slug, unique: true

      t.timestamps
    end
  end
end
