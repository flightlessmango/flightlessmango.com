class ApisBenchesController < ApplicationController
  before_action :authenticate_user!, except: [:fps, :frametime, :full_fps, :full_frametime, :bar]
  def destroy
  @apis_bench = ApisBench.find(params[:id])
  @benchmark = @apis_bench.bench
  respond_to do |format|
    format.html { redirect_to edit_bench_path(@benchmark)}
    format.json { head :no_content }
    format.js
  end
  @apis_bench.inputs.delete_all
  @apis_bench.destroy
end

  def create
    @apis_bench = ApisBench.new(apis_bench_params)
    @benchmark = @apis_bench.bench
    # @apis_bench.creator = current_userl
    respond_to do |format|
      if @apis_bench.save
        format.html { redirect_to edit_bench_path(@benchmark), flash: {success: 'Game Added Successfully'}}
        format.json { render :edit, status: :created, location: @benchmark }
        format.js
      else
        format.html { render :new }
        format.json { render json: @apis_bench.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def frametime
    @apis_bench = ApisBench.find(params[:id])
    render json: @apis_bench.frametime
  end
  
  def fps
    @apis_bench = ApisBench.find(params[:id])
    render json: @apis_bench.fps
  end
  
  def full_frametime
    @apis_bench = ApisBench.find(params[:id])
    render json: @apis_bench.full_frametime
  end
  
  def full_fps
    @apis_bench = ApisBench.find(params[:id])
    render json: @apis_bench.full_fps
  end
  
  def bar
    @apis_bench = ApisBench.find(params[:id])
    render json: @apis_bench.bar
  end
  
  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def apis_bench_params
    params.require(:apis_bench).permit(:api_id, :bench_id)
  end
end