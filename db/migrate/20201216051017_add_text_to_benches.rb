class AddTextToBenches < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :text, :text
  end
end
