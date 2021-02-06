class ExpandVariations < ActiveRecord::Migration[6.0]
  def change
    add_column :variations, :avg, :float
    add_column :variations, :onemin, :float
    add_column :variations, :ninetyseventh, :float
    add_column :variations, :compared, :float
    add_column :variations, :color, :string
    add_column :variations, :benches_game_id, :integer
    add_column :variations, :bench_id, :integer
  end
end
