class AddOrderIndex < ActiveRecord::Migration
  def self.up
    add_index :notes, [:user_id, :user_type, :created_at]
  end

  def self.down
    remove_index :notes, [:user_id, :user_type, :created_at]
  end
end
