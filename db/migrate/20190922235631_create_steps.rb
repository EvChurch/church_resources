# frozen_string_literal: true

class CreateSteps < ActiveRecord::Migration[6.0]
  def change
    create_table :steps, id: :uuid do |t|
      t.string :name
      t.string :snippet
      t.text :content

      t.timestamps
    end
  end
end
