require 'ljsession'

class NotesController < ApplicationController

  before_filter :check_auth, :only => [ :new, :edit, :update, :destroy ]

  def index
    @notes = Note.find_by(params[:dl_sig_owner_user])
    respond_to do |format|
      if @notes.size == 0 and is_owner?
        format.html { redirect_to "#{params["dl_sig_root_loc"]}/new" }
      else
        format.html # index.html.erb
      end
      format.xml  { render :xml => @notes }
      format.rss  { render :xml => @notes }
    end
  end

  def show
    @note = Note.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end

  def new
    @note = Note.new
#    @assets = @fb_session.user_assets_index
    @friends = @fb_session.friends_index

    respond_to do |format|
      format.html { render :layout => "notes_create" }
      format.xml  { render :xml => @note }
    end
  end

  def edit
#    @assets = @fb_session.user_assets_index
    @friends = @fb_session.friends_index
    @note = Note.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "notes_create" }
      format.xml  { render :xml => @note }
    end
  end

  def create

    @note = Note.new(params[:note])
    @note.text = params[:text]
    @note.title = params[:title]
    @note.user_id = params[:dl_sig_user]
    @note.notify_id_list = params[:notify_id_list]
    @note.user_type = "deluux"

    respond_to do |format|
      if @note.save

        create_crosspost
        update_app_link
        send_notifications
        create_friend_news
        
        if @note.title.length > 0
          flash[:notice] = "Added \"#{@note.title}\"!"
        else
          flash[:notice] = "Added your entry!"
        end
        format.html { redirect_to params["dl_sig_root_loc"] }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def create_comment
    @comment = Comment.new
    @comment.note_id = params[:note_id]
    if logged_in?
      create_comment_user_info
    else
      @comment.author_name = params[:author_name]
      @comment.author_url = params[:author_url]
      @comment.author_email = params[:author_email]
    end
    @comment.user_id = params[:dl_sig_owner_user]
    @comment.content = params[:content]
    respond_to do |format|
      if @comment.save
        format.html { redirect_to "#{params[:dl_sig_root_loc]}/"}
      end
    end
  end

  def create_comment_user_info
    user_info = @fb_session.users_show(:user_id => params[:dl_sig_user].to_i)
    @comment.author_name = user_info["display_name"]
    @comment.author_email = user_info["email"]
    @comment.author_url = user_info["url"]
  end
  
  def destroy_comment
    @comment = Comment.find(params[:id].to_i)
    if is_owner? and @comment.user_id.to_i == params[:dl_sig_user].to_i 
      @comment.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to "#{params[:dl_sig_root_loc]}/show/#{@comment.note_id}"}
    end
  end
  
  def update
    @note = Note.find(params[:id])
    @note.text = params[:text]
    @note.title = params[:title]

    respond_to do |format|
      if @note.save
        update_app_link
        send_notifications
        if @note.title.length > 0
          flash[:notice] = "Updated \"#{@note.title}\"!"
        else
          flash[:notice] = "Updated your entry!"
        end
        @notes = Note.find_by(params[:dl_sig_owner_user])
        format.html { redirect_to params["dl_sig_root_loc"] }
        format.xml  { head :ok }
      else
        format.html { redirect_to "#{params["dl_sig_root_loc"]}/edit/#{params[:id]}" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to params["dl_sig_root_loc"] }
      format.xml  { head :ok }
    end
  end

  protected

  def create_crosspost
    if params[:lj_login].length > 0 and params[:lj_password].length > 0
      ljs = LJSession.new(params[:lj_login], params[:lj_password])
      ljs.post_entry(params[:title], params[:text])
    end
  end
  
  def create_friend_news
    friend_news_params = { }
    if @note.title.empty?
      friend_news_params["friend_news[image_description_1]"] = "a blog entry"
    else 
      friend_news_params["friend_news[image_description_1]"] = friend_news_params["friend_news[title]"] = @note.title
    end
    friend_news_params["friend_news[image_url_1]"] = "#{params["dl_sig_root_loc"]}/show/#{@note.id}"
    friend_news_params["friend_news[body]"] = "<a href=\"#{params["dl_sig_root_loc"]}/show/#{@note.id}\">Click to read it</a>"

    friend_news_params["friend_news[target_object]"] = "blog"
    friend_news_params["friend_news[target_action]"] = "wrote"
    @fb_session.friend_news_create( friend_news_params )
  end

  def update_app_link
    update_desc_text = @note.summary
    if @note.summary_shortened?
      update_desc_text += "<p><span class='read_more'><a href='#{params["dl_sig_root_loc"]}/show/#{@note.id}'>Read all of &quot;#{@note.title}&quot;</a></span></p>"
    end
    @notes = Note.find_by(params[:dl_sig_owner_user])
    if @notes.size > 1
      update_desc_text += "<div id='journal_archive'>Other recent entries: "+@notes[1..3].map{ |n|
        "<a href='#{params["dl_sig_root_loc"]}/show/#{n.id}' alt='#{n.title}'>&quot;#{n.title}&quot;</a>"
      }.join(", ")+"</div>"
    end
    @fb_session.links_update({"link[description]" => update_desc_text})
  end

  def send_notifications
    @note.notify_id_list.split(",").each{ |friend_id|
      notify_params = { }
      notify_params["notification[notify_subject]"] = "I mentioned you in a blog post"
      notify_params["notification[notify_message]"] = "I hope you like it! You can read it at "
      notify_params["notification[url]"] = "#{params["dl_sig_root_loc"]}/show/#{@note_id}"
      notify_params["notification[friend_id]"] = friend_id
      notify_params["notification[app_event_id]"] = @note.id
      @fb_session.notifications_create(notify_params)
    }

  end

end
