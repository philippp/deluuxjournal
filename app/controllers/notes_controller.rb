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
    @assets = @fb_session.user_assets_index(:page => 1)
    @friends = @fb_session.friends_index

    respond_to do |format|
      format.html { render :layout => "notes_create" }
      format.xml  { render :xml => @note }
    end
  end

  def edit
    @assets = @fb_session.user_assets_index
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

        if @note.title.length > 0
          flash[:notice] = "Added \"#{@note.title}\"!"
        else
          flash[:notice] = "Added your entry!"
        end
        @notes = Note.find_by(params[:dl_sig_owner_user])
        format.html { redirect_to params["dl_sig_root_loc"] }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def create_comment
    @comment = Comment.new
    @comment.note_id = params[:note_id]
    @comment.author_name = params[:author_name]
    @comment.author_url = params[:author_url]
    @comment.author_email = params[:author_email]
    @comment.content = params[:content]
    respond_to do |format|
      if @comment.save
        format.html { redirect_to "#{params[:dl_sig_root_loc]}/show/#{@comment.note_id}"}
      end
    end
  end

  def destroy_comment
    if is_owner?
      @comment = Comment.destroy()
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

  def update_app_link
    update_desc_text = @note.summary
    if @note.summary_shortened?
      update_desc_text += "&nbsp;<span class='read_more'><a href='#{params["dl_sig_root_loc"]}/show/#{@note.id}'>Read all of &quot;#{@note.title}&quot;</a></span><br/>"
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
