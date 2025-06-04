# frozen_string_literal: true

class AddFluroFormUrlToLocationConnectionSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :location_connection_steps, :fluro_form_url, :string
  end
end
