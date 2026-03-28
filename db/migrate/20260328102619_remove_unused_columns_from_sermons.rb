class RemoveUnusedColumnsFromSermons < ActiveRecord::Migration[7.2]
  def change
    remove_column :sermons, :video_url, :string
    remove_column :sermons, :content, :text
    remove_column :sermons, :connect_group_notes, :text
    remove_column :sermons, :sermon_notes, :text
    remove_column :sermons, :snippet, :string
  end
end
