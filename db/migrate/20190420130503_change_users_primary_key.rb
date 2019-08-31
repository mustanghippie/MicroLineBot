class ChangeUsersPrimaryKey < ActiveRecord::Migration[5.2]
  def change
    drop_table :users 
    create_table :users, id:false, primary_key: :uid do |t|
      t.string :uid, null: false
      t.string :name
      t.timestamps
    end
    
  end
end
