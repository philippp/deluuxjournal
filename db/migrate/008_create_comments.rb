class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :note_id
      t.string :author_name
      t.string :author_email
      t.string :author_url
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
