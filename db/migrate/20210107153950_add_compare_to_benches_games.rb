class AddCompareToBenchesGames < ActiveRecord::Migration[6.0]
  def change
    add_column :benches_games, :compare_id, :integer
  end
end
