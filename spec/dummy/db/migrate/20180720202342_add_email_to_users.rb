class AddEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string, null: true
  end
end
