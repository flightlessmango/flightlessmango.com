class BenchesGamesController < ApplicationController
  before_action :authenticate_user!, except: [:fps, :frametime, :full_fps, :full_frametime, :bar, :gpu, :cpu, :show]
  def destroy
  @benches_game = BenchesGame.find(params[:id])
  @benchmark = @benches_game.bench
  respond_to do |format|
    format.html { redirect_to edit_bench_path(@benchmark)}
    format.json { head :no_content }
    format.js
  end
  @benches_game.inputs.delete_all
  @benches_game.destroy
end

  def create
    @benches_game = BenchesGame.new(benches_game_params)
    @benchmark = @benches_game.bench
    # @benches_game.creator = current_userl
    respond_to do |format|
      if @benches_game.save
        format.html { redirect_to edit_bench_path(@benchmark), flash: {success: 'Game Added Successfully'}}
        format.json { render :edit, status: :created, location: @benchmark }
        format.js
      else
        format.html { render :new }
        format.json { render json: @benches_game.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def show
    @benches_game = BenchesGame.find(params[:id])
    @benchmark = @benches_game.bench
    @graph_type = params[:graph_type]
    # @benches_game.creator = current_userl
    respond_to do |format|
        format.json { render :show, status: :created, location: @benchmark }
      end
  end

  def frametime
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.frametime
  end
  
  def fps
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.fps
  end
  
  def full_frametime
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.full_frametime
  end
  
  def full_fps
    @benches_game = BenchesGame.find(params[:id])
    respond_to do |format|
      format.json {render json: @benches_game.full_fps}
      format.html {render json: @benches_game.full_fps}
    end
  end
  
  def bar
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.bar
  end
  
  def gpu
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.gpu
  end
  
  def cpu
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.cpu
  end
  
  def avgcpu
    @benches_game = BenchesGame.find(params[:id])
    render json: @benches_game.avgcpu
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def benches_game_params
    params.permit(:game_id, :bench_id)
  end
end