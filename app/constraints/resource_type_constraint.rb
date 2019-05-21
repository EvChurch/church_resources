# frozen_string_literal: true

class ResourceTypeConstraint
  def matches?(request)
    request.params[:resource_type].blank? || Resource::TYPES.keys.include?(request.params[:resource_type].to_sym)
  end
end
