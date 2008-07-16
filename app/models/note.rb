class Note < ActiveRecord::Base

  def self.max_summary_length() 250; end

  def self.find_by(user_id, type = "deluux")
    self.find(:all, :conditions => ["user_id = ? AND user_type = ?", user_id, type],
              :order => "created_at desc")
  end

  def before_save
    raw_text = ""
    Hpricot(self.text).traverse_text{ |text_node|
      raw_text << text_node.content+"<br/>"
    }

    if raw_text.size > Note.max_summary_length
      self.summary = raw_text[0..Note.max_summary_length]+"..."
    else
      self.summary = raw_text
    end
  end

  def summary_shortened?
    return self.summary.size > Note.max_summary_length # will be 3 chars more due to ellipses
  end

end
