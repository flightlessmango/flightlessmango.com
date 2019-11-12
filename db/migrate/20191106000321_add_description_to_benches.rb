class AddDescriptionToBenches < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :description, :text
  end
end
