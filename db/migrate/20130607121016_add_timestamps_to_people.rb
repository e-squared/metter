class AddTimestampsToPeople < ActiveRecord::Migration
  def change
    add_timestamps :people
  end
end

