# frozen_string_literal: true

class Types::BaseField < GraphQL::Schema::Field
  argument_class Types::BaseArgument

  def resolve_field(obj, args, ctx)
    resolve(obj, args, ctx)
  end
end
