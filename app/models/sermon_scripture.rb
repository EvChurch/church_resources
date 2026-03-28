# frozen_string_literal: true

class SermonScripture < ApplicationRecord
  belongs_to :sermon
  belongs_to :scripture, class_name: '::Scripture'

  before_save :fetch_content, if: :range_changed?

  def self.ransackable_attributes(_auth_object = nil)
    %w[content created_at id range sermon_id scripture_id updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[sermon scripture]
  end

  protected

  def fetch_content
    self.content = Mechanize.new.get('https://www.biblegateway.com/passage/',
                                     search: "#{scripture.name} #{range}".strip,
                                     version: 'CSB').at('.passage-content').to_s
  end
end
