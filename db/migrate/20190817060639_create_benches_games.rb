class CreateBenchesGames < ActiveRecord::Migration[5.2]
  def change
    create_table :benches_games do |t|
      t.integer :game_id
      t.integer :bench_id

      t.timestamps
    end
  end
end
