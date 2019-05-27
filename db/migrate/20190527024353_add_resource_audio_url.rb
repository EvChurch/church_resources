# frozen_string_literal: true

class AddResourceAudioUrl < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :audio_url, :string
  end
end
