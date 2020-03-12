class AddCompareToBenches < ActiveRecord::Migration[6.0]
  def change
    add_column :benches, :compare_to, :integer
  end
end
