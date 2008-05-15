class UserType < ActiveRecord::Migration
  def self.up
    add_column :notes, :user_type, :string
    add_index :notes, [:user_id, :user_type]
  end

  def self.down
    remove_column :notes, :user_type
    remove_index :notes, [:user_id, :user_type]
  end
end
