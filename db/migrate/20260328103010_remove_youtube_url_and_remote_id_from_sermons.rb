class RemoveYoutubeUrlAndRemoteIdFromSermons < ActiveRecord::Migration[7.2]
  def change
    remove_column :sermons, :youtube_url, :string
    remove_column :sermons, :remote_id, :string
  end
end
