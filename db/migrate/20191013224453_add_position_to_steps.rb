# frozen_string_literal: true

class AddPositionToSteps < ActiveRecord::Migration[6.0]
  class Step < ApplicationRecord; end

  def up
    add_column :steps, :position, :integer
    Step.order(:updated_at).each.with_index(1) do |step, index|
      step.update(position: index)
    end
  end

  def down
    remove_column :steps, :position
  end
end
