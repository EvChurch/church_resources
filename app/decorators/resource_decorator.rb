# frozen_string_literal: true

class ResourceDecorator < ApplicationDecorator
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
