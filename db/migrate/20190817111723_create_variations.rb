class CreateVariations < ActiveRecord::Migration[5.2]
  def change
    create_table :variations do |t|
      t.string :name
      t.integer :type_id

      t.timestamps
    end
  end
end
