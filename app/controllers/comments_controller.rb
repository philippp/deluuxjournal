class CommentsController < ApplicationController

  def create
    @comment = Note.new(params[:note])
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


end
