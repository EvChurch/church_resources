# frozen_string_literal: true

class RemoveYoutubeUrlAndRemoteIdFromSermons < ActiveRecord::Migration[7.2]
  def change
    change_table :sermons, bulk: true do |t|
      t.remove :youtube_url, type: :string
      t.remove :remote_id, type: :string
    end
  end
end
