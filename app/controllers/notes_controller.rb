require 'ljsession'

class NotesController < ApplicationController

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
    @friends = @fb_session.friends_index
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  def edit
    @assets = @fb_session.user_assets_index
    @friends = @fb_session.friends_index
    @note = Note.find(params[:id])
  end

  def create
    @note = Note.new(params[:note])
    @note.text = params[:text]
    @note.title = params[:title]
    @note.user_id = params[:dl_sig_user]
    @note.notify_id_list = params[:notify_id_list]
    @note.user_type = "deluux"
    create_crosspost

    respond_to do |format|
      if @note.save
        if @note.title.length > 0
          flash[:notice] = "Added \"#{@note.title}\"!"
        else
          flash[:notice] = "Added your entry!"
        end

        format.html {
          app_redirect_to :action => "index"
        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update

    @note = Note.find(params[:id])
    respond_to do |format|
      @note.text = params[:text]
      @note.title = params[:title]

      if @note.save
        if @note.title.length > 0
          flash[:notice] = "Updated \"#{@note.title}\"!"
        else
          flash[:notice] = "Updated your entry!"
        end

        format.html { app_redirect_to :action => "index" }
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
      format.html { app_redirect_to :action => :index }
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

end
