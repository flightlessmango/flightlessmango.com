class AddVariationIdToInput < ActiveRecord::Migration[5.2]
  def change
    add_column :inputs, :variation_id, :integer
  end
end
