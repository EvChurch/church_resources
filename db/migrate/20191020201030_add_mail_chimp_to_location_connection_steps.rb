# frozen_string_literal: true

class AddMailChimpToLocationConnectionSteps < ActiveRecord::Migration[6.0]
  def change
    add_column :location_connection_steps, :mail_chimp_user_id, :string
    add_column :location_connection_steps, :mail_chimp_audience_id, :string
  end
end
