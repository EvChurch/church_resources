# frozen_string_literal: true

class Resource::Connection::Scripture < ApplicationRecord
  belongs_to :resource
  belongs_to :scripture, class_name: '::Scripture'

  before_save :fetch_content, if: :range_changed?

  protected

  def fetch_content
    self.content = Mechanize.new.get('https://www.biblegateway.com/passage/',
                                     search: "#{scripture.name} #{range}".strip,
                                     version: 'CSB').at('.passage-content').to_s
  end
end
