# frozen_string_literal: true

class Resource::Connection::Author < ApplicationRecord
  belongs_to :resource
  belongs_to :author
end
