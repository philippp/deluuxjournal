class AddFriendNotifiedList < ActiveRecord::Migration
  def self.up
    add_column :notes, :notify_id_list, :string
  end

  def self.down
    remove_column :notes, :notify_id_list
  end
end
