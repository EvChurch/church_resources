# frozen_string_literal: true

class ResourceTypeConstraint
  def matches?(request)
    Resource::TYPES.keys.include?(request.params[:resource_type].to_sym) || request.params[:resource_type].blank?
  end
end
