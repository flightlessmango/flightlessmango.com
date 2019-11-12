class CreateComputers < ActiveRecord::Migration[6.0]
  def change
    create_table :computers do |t|
      t.string :cpu
      t.string :gpu
      t.string :ram
      t.string :memory
      t.string :os
      t.string :kernel
      t.string :driver
      t.integer :user_id
      t.integer :log_id

      t.timestamps
    end
  end
end
