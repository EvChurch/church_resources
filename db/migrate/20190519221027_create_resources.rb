# frozen_string_literal: true

class CreateResources < ActiveRecord::Migration[6.0]
  def change
    create_table :resources, id: :uuid do |t|
      t.string :type
      t.string :name
      t.string :snippet
      t.text :content
      t.timestamp :published_at
      t.timestamp :featured_at
      t.string :video_url

      t.timestamps
    end
  end
end
