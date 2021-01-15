# frozen_string_literal: true

class AddRegistrationUrlToLocationEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :location_events, :registration_url, :string
  end
end
