class ChangeColumnNullUidToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :uid, false
  end
end
