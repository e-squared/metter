class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login,            :null => false
      t.string :password_digest,  :null => false
      t.string :first_name,       :null => false
      t.string :last_name,        :null => false

      t.boolean :trashed, :default => false

      t.timestamps
    end

    add_index :users, :login, :unique => true
    add_index :users, :trashed
    add_index :users, :created_at
    add_index :users, :updated_at
  end
end

