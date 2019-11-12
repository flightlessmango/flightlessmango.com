class AddSlugToBench < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :slug, :string
    add_index :benches, :slug, unique: true
  end
end
