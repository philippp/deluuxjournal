class Title < ActiveRecord::Migration
  def self.up
    add_column :notes, :title, :string
  end

  def self.down
    remove_column :notes, :title
  end
end
