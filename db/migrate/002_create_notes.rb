class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :user_id
      t.text :text
      t.integer :blog_id

      t.timestamps
    end
    add_index :notes, :user_id
    add_index :notes, :blog_id
  end

  def self.down
    drop_table :notes
  end
end
