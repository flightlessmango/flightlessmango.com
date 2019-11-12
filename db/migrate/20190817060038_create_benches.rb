class CreateBenches < ActiveRecord::Migration[5.2]
  def change
    create_table :benches do |t|
      t.string :name
      t.string :youtubeid
      t.integer :computer_id
      t.boolean :published

      t.timestamps
    end
  end
end
