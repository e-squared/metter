class AddWikipediaDataToPeople < ActiveRecord::Migration
  def change
    add_column :people, :wikipedia_image_url, :string, :after => :wikipedia_identifier, :limit => 1024
    add_column :people, :wikipedia_about_html, :text, :after => :wikipedia_image_url
  end
end

