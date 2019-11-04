# frozen_string_literal: true

class AddFeaturedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :steps, :featured_at, :timestamp
    add_column :location_events, :featured_at, :timestamp
    add_index :steps, :featured_at
    add_index :location_events, :featured_at
  end
end
