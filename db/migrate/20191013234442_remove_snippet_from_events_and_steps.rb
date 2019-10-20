# frozen_string_literal: true

class RemoveSnippetFromEventsAndSteps < ActiveRecord::Migration[6.0]
  def change
    remove_column :steps, :snippet, :string
    remove_column :location_events, :snippet, :string
  end
end
