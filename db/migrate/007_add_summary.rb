class AddSummary < ActiveRecord::Migration
  def self.up
    add_column :notes, :summary, :string
  end

  def self.down
    remove_column :notes, :summary
  end
end
