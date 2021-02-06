class Add < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :variation_id, :integer
  end
end
