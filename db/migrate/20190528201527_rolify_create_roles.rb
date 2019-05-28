# frozen_string_literal: true

class RolifyCreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name
      t.references :resource, polymorphic: true, type: :uuid

      t.timestamps
    end

    create_table :users_roles, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :role, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end

    add_index :roles, %i[name resource_type resource_id], unique: true
    add_index :users_roles, %i[user_id role_id], unique: true
  end
end
