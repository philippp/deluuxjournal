require 'ljsession'

class NotesController < ApplicationController

  layout nil

  before_filter :check_auth, :only => [ :new, :edit, :update, :destroy ]

  def index
    @notes = Note.find_by(params[:dl_sig_owner_user])

    respond_to do |format|
      format.html # index.html.erb
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
    @assets = @fb_session.user_assets_index
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def create
    @note = Note.new(params[:note])
    @note.text = params[:text]
    @note.title = params[:title]
    @note.user_id = params[:dl_sig_user]
    @note.user_type = "deluux"
    create_crosspost
    friends_found = params.select{|k,v| v if k[0,14] == "friend_select_" and v != ""}

    respond_to do |format|
      if @note.save
        flash[:notice] = 'Note was successfully created.'
        format.html { redirect_to params[:dl_sig_root_loc] }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to params[:dl_sig_root_loc] }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to params[:dl_sig_root_loc] }
      format.xml  { head :ok }
    end
  end

  protected

  def create_crosspost
    if params[:lj_login] and params[:lj_password]
      ljs = LJSession.new(params[:lj_login], params[:lj_password])
      ljs.post_entry(params[:title], params[:text])
    end
  end

end
