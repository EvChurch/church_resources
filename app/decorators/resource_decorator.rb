# frozen_string_literal: true

class ResourceDecorator < ApplicationDecorator
  decorates_association :connection_scriptures

  def action
    'view'
  end

  def type_title
    type_param.titleize
  end

  def type_param
    type.demodulize.downcase
  end
end
