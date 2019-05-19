# frozen_string_literal: true

class Resource::Connection::Series < ApplicationRecord
  belongs_to :resource
  belongs_to :series
end
