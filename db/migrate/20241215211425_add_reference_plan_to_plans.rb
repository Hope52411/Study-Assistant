class AddReferencePlanToPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :plans, :reference_plan, :text
  end
end
