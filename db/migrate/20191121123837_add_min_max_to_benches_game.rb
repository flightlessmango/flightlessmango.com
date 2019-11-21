class AddMinMaxToBenchesGame < ActiveRecord::Migration[6.0]
  def change
    add_column :benches_games, :min, :integer
    add_column :benches_games, :max, :integer
  end
end
