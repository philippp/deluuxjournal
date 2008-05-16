require 'livejournal/login'
require 'livejournal/entry'


class LJSession

  def initialize(user, password)
    @user = LiveJournal::User.new(user, password)
    login_request = LiveJournal::Request::Login.new(@user)
    login_request.run
  end

  def post_entry(subject, event_txt)
    e = LiveJournal::Entry.new()
    e.event = event_txt
    e.subject = subject
    e.time = Time.now.gmtime
    post_request = LiveJournal::Request::PostEvent.new(@user, e)
    post_request.run
  end

end
