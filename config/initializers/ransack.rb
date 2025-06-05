# frozen_string_literal: true

Rails.application.config.to_prepare do
  ActiveStorage::Attachment.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[id record_type record_id name blob_id created_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[record blob]
    end
  end

  ActiveStorage::Blob.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      %w[id key filename content_type metadata service_name byte_size checksum created_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[attachments preview_image_attachment]
    end
  end
end 