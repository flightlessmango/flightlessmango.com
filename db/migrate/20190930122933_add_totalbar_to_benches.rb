class AddTotalbarToBenches < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :totalbar, :jsonb
  end
end
