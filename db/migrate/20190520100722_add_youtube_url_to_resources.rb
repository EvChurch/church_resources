class AddYoutubeUrlToResources < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :youtube_url, :string
  end
end
