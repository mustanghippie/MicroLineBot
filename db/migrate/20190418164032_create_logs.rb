class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.string :uid
      t.string :action

      t.timestamps
    end
  end
end
