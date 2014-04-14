class CreateContactings < ActiveRecord::Migration
  def change
    create_table :contactings do |t|
      t.string  :token, :null => false, :length => 16

      t.string  :name,    :null => false
      t.string  :email,   :null => false
      t.string  :subject, :null => false
      t.text    :message

      t.string  :user_agent
      t.string  :ip_address

      t.timestamps
    end

    add_index :contactings, :token, :unique => true
  end
end
