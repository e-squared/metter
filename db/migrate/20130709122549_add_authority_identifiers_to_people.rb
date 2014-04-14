class AddAuthorityIdentifiersToPeople < ActiveRecord::Migration
  def change
    add_column :people, :gnd_identifier, :string
    add_column :people, :viaf_identifier, :string
    add_column :people, :lccn_identifier, :string
  end
end
