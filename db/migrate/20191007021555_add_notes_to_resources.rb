class AddNotesToResources < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :sermon_notes, :text
    add_column :resources, :connect_group_notes, :text
  end
end
