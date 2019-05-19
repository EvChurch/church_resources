# frozen_string_literal: true

class Resource::Connection::Topic < ApplicationRecord
  belongs_to :resource
  belongs_to :topic
end
