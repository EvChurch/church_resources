# frozen_string_literal: true

class Resource::Connection::Scripture < ApplicationRecord
  belongs_to :resource
  belongs_to :author
end
