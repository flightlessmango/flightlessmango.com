class AddTotalcpuToBenches < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :totalcpu, :jsonb
  end
end
