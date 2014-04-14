class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :token, :null => false
      t.string :type,  :null => false
      t.date   :date, :null => false
      t.text   :description
    end

    add_index :events, :token, :unique => true
    add_index :events, :type
    add_index :events, :date
  end
end

