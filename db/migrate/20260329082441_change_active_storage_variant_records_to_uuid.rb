# frozen_string_literal: true

class ChangeActiveStorageVariantRecordsToUuid < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/BulkChangeTable, Rails/DangerousColumnNames
  def up
    remove_index :active_storage_variant_records, name: 'index_active_storage_variant_records_uniqueness'
    remove_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id

    add_column :active_storage_variant_records, :uuid_id, :uuid, default: 'gen_random_uuid()', null: false
    remove_column :active_storage_variant_records, :id
    rename_column :active_storage_variant_records, :uuid_id, :id
    execute 'ALTER TABLE active_storage_variant_records ADD PRIMARY KEY (id);'

    add_index :active_storage_variant_records, %i[blob_id variation_digest],
              name: 'index_active_storage_variant_records_uniqueness', unique: true
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end

  def down
    remove_index :active_storage_variant_records, name: 'index_active_storage_variant_records_uniqueness'
    remove_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id

    add_column :active_storage_variant_records, :bigint_id, :bigserial
    remove_column :active_storage_variant_records, :id
    rename_column :active_storage_variant_records, :bigint_id, :id
    execute 'ALTER TABLE active_storage_variant_records ADD PRIMARY KEY (id);'

    add_index :active_storage_variant_records, %i[blob_id variation_digest],
              name: 'index_active_storage_variant_records_uniqueness', unique: true
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
  # rubocop:enable Rails/BulkChangeTable, Rails/DangerousColumnNames
end
