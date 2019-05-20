# frozen_string_literal: true

class ResourceTypeConstraint
  def matches?(request)
    Resource::TYPES.include?(request.params[:resource_type]) || request.params[:resource_type].blank?
  end
end
