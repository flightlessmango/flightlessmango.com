class AddPosToInputs < ActiveRecord::Migration[6.0]
  def change
    add_column :inputs, :pos, :integer
    add_column :inputs, :name, :string
  end
end
