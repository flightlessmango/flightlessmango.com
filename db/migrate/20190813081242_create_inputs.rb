class CreateInputs < ActiveRecord::Migration[5.2]
  def change
    create_table :inputs do |t|
      t.integer :type_id
      t.integer :bench_id
      t.float :fps
      t.float :frametime
      t.float :cpu
      t.float :gpu
      t.string :color
      t.string :driver
      t.integer :benches_game_id
      t.integer :game_id

      t.timestamps
    end
  end
end
