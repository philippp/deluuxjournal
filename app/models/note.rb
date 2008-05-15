class Note < ActiveRecord::Base

  def self.find_by(user_id, type = "deluux")
    self.find(:all, :conditions => ["user_id = ? AND user_type = ?", user_id, type],
              :order => "created_at desc")
  end

end
