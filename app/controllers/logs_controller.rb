class LogsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :fps, :frametime, :full_fps, :full_frametime, :bar, :totalbar, :create, :cpuavg, :cpu]
  
  def index
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true).where.not(source: 'mango').where.not(name: 'MangoHud Uploader').includes(:logs).paginate(page: params[:page], per_page: 30)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    @log = Log.find(params[:id])
    @game = @log.game
  end
  
  def new
    @log = Log.new
    @game = Game.find(params[:game_id])
  end
  
  def show
    @log = Log.find(params[:id])
    @game = @log.game
    respond_to do |format|
      format.html {}
      format.js
      format.json { render :show, location: @log }
    end
  end
  
  def create
    @log = Log.new(log_params)
    @game = @log.game
    respond_to do |format|
      if @log.save(:validate => false)
        if @log.uploads.any?
          if request.user_agent == "mangohud"
            @log.parse_upload("mangohud")
          else
            @log.parse_upload("other")
          end
        end
        if request.user_agent == "mangohud"
          format.html { redirect_to log_path(@log), notice: 'Logmark was successfully created.' }
        else 
          format.html { redirect_to edit_game_log_path(@game, @log), notice: 'Logmark was successfully created.' }
        end
        format.js
      else

      end
    end
    @game.update(num_logs: @game.logs.count)
  end
  
  def update
  @log = Log.find(params[:id])
  @game = @log.game
  respond_to do |format|
    if @log.update(log_params)
      if request.user_agent == "mangohud"
        @log.parse_upload("mangohud")
      else
        @log.parse_upload("other")
      end
      if params[:attachment]
        format.html { redirect_to edit_game_log_path(@game, @log), flash: {success: 'Successfully uploaded'} }
      else
        format.html { redirect_to edit_game_log_path(@game, @log), flash: {success: 'Successfully updated logmark'} }
      end
      format.json { render :show, status: :ok, location: @log }
      format.js
    else
      format.html { render :edit, flash: {warning: 'Failed to upload'} }
      format.json { render json: @log.errors, status: :unprocessable_entity }
      format.js
    end
  end
end

def destroy
  @log = Log.find(params[:id])
  @log.destroy
  @log.game.update(num_logs: @game.logs.count)
  redirect_to user_path(current_user)
end

def frametime
  @log = Log.find(params[:id])
  render json: @log.frametime
end

def fps
  @log = Log.find(params[:id])
  render json: @log.fps
end

def bar
  @log = Log.find(params[:id])
  render json: @log.bar
end

def cpu
  @log = Log.find(params[:id])
  render json: @log.cpu
end

def cpuavg
  @log = Log.find(params[:id])
  render json: @log.cpuavg
end

def new_benchmark
  @log = Log.new
end

def edit_benchmark
  @log = Log.find(params[:log_id])
  @game = @log.game
end

# def update_blob_filename
#   @log = ActiveStorage::Blob.find(params[:blob_id]).attachments.first.record
#   if @log.user == current_user
#     ActiveStorage::Blob.find(params[:blob_id]).update(filename: params[:filename])
#     @log.parse_upload
#   end
# end

def update_attachment_name
  @log = ActiveStorage::Attachment.find(params[:attachment_id]).record
  if @log.user == current_user
    ActiveStorage::Attachment.find(params[:attachment_id]).update(display_name: params[:name].to_s)
    @log.parse_upload
  end
end

def update_attachment_color
  @log = ActiveStorage::Attachment.find(params[:attachment_id]).record
  if @log.user == current_user
    ActiveStorage::Attachment.find(params[:attachment_id]).update(color: "#" + params[:color].to_s)
    @log.parse_upload
  end
end

private
# Never trust parameters from the scary internet, only allow the white list through.
def log_params
  params.require(:log).permit(:fps, :frametime, :bar, :game_id, :user_id, :compare_to, :max, :min, :computer_id, :title, :text, uploads: [])
end
  
end
