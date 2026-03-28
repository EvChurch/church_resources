# frozen_string_literal: true

class SermonScriptureDecorator < ApplicationDecorator
  def name
    "#{scripture.name} #{range}"
  end
end
