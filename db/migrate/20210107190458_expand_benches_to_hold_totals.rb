class ExpandBenchesToHoldTotals < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :avg, :float
    add_column :benches, :onemin, :float
    add_column :benches, :ninetyseventh, :float
    add_column :benches, :compared, :float
  end
end
