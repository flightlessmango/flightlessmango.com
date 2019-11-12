class CreateLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :logs do |t|
      t.jsonb :fps
      t.jsonb :frametime
      t.jsonb :bar
      t.timestamps
    end
  end
end
