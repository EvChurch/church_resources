# frozen_string_literal: true

class Resource::Connection::ScriptureDecorator < ApplicationDecorator
  def name
    "#{scripture.name} #{range}"
  end
end
