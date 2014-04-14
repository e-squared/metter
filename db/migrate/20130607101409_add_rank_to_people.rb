class AddRankToPeople < ActiveRecord::Migration
  def change
    add_column :people, :rank, :integer, :default => 0

    add_index :people, :rank
  end
end

