class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :token, :null => false, :length => 16
      t.string :name, :null => false
      t.text :description, :null => false
      t.date :date_of_birth, :null => false
      t.string :place_of_birth
      t.date :date_of_death
      t.string :place_of_death
      t.text :alternative_names, :array => true
      t.string :wikipedia_identifier, :length => 16
    end

    add_index :people, :token, :unique => true
    add_index :people, :name
  end
end

