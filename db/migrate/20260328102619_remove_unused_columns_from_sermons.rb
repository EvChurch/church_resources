# frozen_string_literal: true

class RemoveUnusedColumnsFromSermons < ActiveRecord::Migration[7.2]
  def change
    change_table :sermons, bulk: true do |t|
      t.remove :video_url, type: :string
      t.remove :content, type: :text
      t.remove :connect_group_notes, type: :text
      t.remove :sermon_notes, type: :text
      t.remove :snippet, type: :string
    end
  end
end
