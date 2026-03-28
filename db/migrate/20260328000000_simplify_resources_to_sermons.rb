# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength
class SimplifyResourcesToSermons < ActiveRecord::Migration[7.2]
  def up
    # --- Rename resources -> sermons ---
    rename_table :resources, :sermons
    remove_column :sermons, :type

    # --- Rename join tables ---
    rename_table :resource_connection_authors, :sermon_authors
    rename_table :resource_connection_scriptures, :sermon_scriptures
    rename_table :resource_connection_series, :sermon_series
    rename_table :resource_connection_topics, :sermon_topics

    # --- Update foreign keys and rename resource_id -> sermon_id on join tables ---
    # sermon_authors
    remove_foreign_key :sermon_authors, column: :resource_id
    remove_foreign_key :sermon_authors, :authors
    rename_column :sermon_authors, :resource_id, :sermon_id
    add_foreign_key :sermon_authors, :sermons, column: :sermon_id, on_delete: :cascade
    add_foreign_key :sermon_authors, :authors, on_delete: :cascade

    # sermon_scriptures
    remove_foreign_key :sermon_scriptures, column: :resource_id
    remove_foreign_key :sermon_scriptures, :scriptures
    rename_column :sermon_scriptures, :resource_id, :sermon_id
    add_foreign_key :sermon_scriptures, :sermons, column: :sermon_id, on_delete: :cascade
    add_foreign_key :sermon_scriptures, :scriptures, on_delete: :cascade

    # sermon_series
    remove_foreign_key :sermon_series, column: :resource_id
    remove_foreign_key :sermon_series, :series
    rename_column :sermon_series, :resource_id, :sermon_id
    add_foreign_key :sermon_series, :sermons, column: :sermon_id, on_delete: :cascade
    add_foreign_key :sermon_series, :series, on_delete: :cascade

    # sermon_topics
    remove_foreign_key :sermon_topics, column: :resource_id
    remove_foreign_key :sermon_topics, column: :topic_id
    rename_column :sermon_topics, :resource_id, :sermon_id
    add_foreign_key :sermon_topics, :sermons, column: :sermon_id, on_delete: :cascade
    add_foreign_key :sermon_topics, :category_topics, column: :topic_id, on_delete: :cascade

    # --- Drop unused tables ---
    drop_table :location_connection_steps
    drop_table :location_events
    drop_table :location_prayers
    drop_table :location_services
    drop_table :locations
    drop_table :steps

    # --- Update polymorphic type references ---
    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET record_type = 'Sermon'
      WHERE record_type IN ('Resource', 'Resource::Sermon');
    SQL

    execute <<~SQL.squish
      UPDATE active_admin_comments
      SET resource_type = 'Sermon'
      WHERE resource_type IN ('Resource', 'Resource::Sermon');
    SQL

    execute <<~SQL.squish
      UPDATE friendly_id_slugs
      SET sluggable_type = 'Sermon'
      WHERE sluggable_type IN ('Resource', 'Resource::Sermon');
    SQL
  end

  def down
    # --- Reverse polymorphic type references ---
    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET record_type = 'Resource'
      WHERE record_type = 'Sermon';
    SQL

    execute <<~SQL.squish
      UPDATE active_admin_comments
      SET resource_type = 'Resource::Sermon'
      WHERE resource_type = 'Sermon';
    SQL

    execute <<~SQL.squish
      UPDATE friendly_id_slugs
      SET sluggable_type = 'Resource'
      WHERE sluggable_type = 'Sermon';
    SQL

    # --- Recreate dropped tables ---
    create_table :steps, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string 'name'
      t.text 'content'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.integer 'position'
      t.datetime 'featured_at', precision: nil
      t.index ['featured_at'], name: 'index_steps_on_featured_at'
    end

    create_table :locations, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string 'name'
      t.string 'snippet'
      t.text 'content'
      t.string 'address'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end

    create_table :location_services, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.datetime 'start_at', precision: nil
      t.datetime 'end_at', precision: nil
      t.uuid 'location_id', null: false
      t.string 'elvanto_form_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['location_id'], name: 'index_location_services_on_location_id'
    end

    create_table :location_prayers, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string 'name'
      t.string 'snippet'
      t.text 'content'
      t.uuid 'location_id', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['location_id'], name: 'index_location_prayers_on_location_id'
    end

    create_table :location_events, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.datetime 'start_at', precision: nil
      t.datetime 'end_at', precision: nil
      t.string 'name'
      t.text 'content'
      t.string 'address'
      t.string 'elvanto_form_id'
      t.string 'facebook_url'
      t.uuid 'location_id', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.datetime 'featured_at', precision: nil
      t.string 'registration_url'
      t.index ['featured_at'], name: 'index_location_events_on_featured_at'
      t.index ['location_id'], name: 'index_location_events_on_location_id'
    end

    create_table :location_connection_steps, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string 'elvanto_form_id'
      t.text 'content'
      t.uuid 'step_id', null: false
      t.uuid 'location_id', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.string 'mail_chimp_user_id'
      t.string 'mail_chimp_audience_id'
      t.string 'fluro_form_url'
      t.index ['location_id'], name: 'index_location_connection_steps_on_location_id'
      t.index ['step_id'], name: 'index_location_connection_steps_on_step_id'
    end

    # Restore foreign keys on location tables
    add_foreign_key :location_connection_steps, :locations, on_delete: :cascade
    add_foreign_key :location_connection_steps, :steps, on_delete: :cascade
    add_foreign_key :location_events, :locations, on_delete: :cascade
    add_foreign_key :location_prayers, :locations, on_delete: :cascade
    add_foreign_key :location_services, :locations, on_delete: :cascade

    # --- Reverse foreign keys and rename sermon_id -> resource_id on join tables ---
    # sermon_topics -> resource_connection_topics
    remove_foreign_key :sermon_topics, column: :sermon_id
    remove_foreign_key :sermon_topics, column: :topic_id
    rename_column :sermon_topics, :sermon_id, :resource_id
    rename_table :sermon_topics, :resource_connection_topics
    add_foreign_key :resource_connection_topics, :category_topics, column: :topic_id, on_delete: :cascade

    # sermon_series -> resource_connection_series
    remove_foreign_key :sermon_series, column: :sermon_id
    remove_foreign_key :sermon_series, :series
    rename_column :sermon_series, :sermon_id, :resource_id
    rename_table :sermon_series, :resource_connection_series

    # sermon_scriptures -> resource_connection_scriptures
    remove_foreign_key :sermon_scriptures, column: :sermon_id
    remove_foreign_key :sermon_scriptures, :scriptures
    rename_column :sermon_scriptures, :sermon_id, :resource_id
    rename_table :sermon_scriptures, :resource_connection_scriptures

    # sermon_authors -> resource_connection_authors
    remove_foreign_key :sermon_authors, column: :sermon_id
    remove_foreign_key :sermon_authors, :authors
    rename_column :sermon_authors, :sermon_id, :resource_id
    rename_table :sermon_authors, :resource_connection_authors

    # --- Rename sermons -> resources and restore type column ---
    rename_table :sermons, :resources
    add_column :resources, :type, :string

    # Restore foreign keys referencing :resources
    add_foreign_key :resource_connection_authors, :resources, on_delete: :cascade
    add_foreign_key :resource_connection_authors, :authors, on_delete: :cascade
    add_foreign_key :resource_connection_scriptures, :resources, on_delete: :cascade
    add_foreign_key :resource_connection_scriptures, :scriptures, on_delete: :cascade
    add_foreign_key :resource_connection_series, :resources, on_delete: :cascade
    add_foreign_key :resource_connection_series, :series, on_delete: :cascade
    add_foreign_key :resource_connection_topics, :resources, on_delete: :cascade
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength
