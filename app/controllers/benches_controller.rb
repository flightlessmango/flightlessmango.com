class BenchesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :fps, :frametime, :full_fps, :full_frametime, :bar, :totalbar, :total_cpu, :recording]
  def index
    if user_signed_in? && current_user.admin?
      @benchmarks = Bench.all.paginate(page: params[:page], per_page: 15)
    else
      @benchmarks = Bench.where(published: true).paginate(page: params[:page], per_page: 15)
    end
  end
  
  def show
    @benchmark = Bench.friendly.find(params[:id])
    @types = Type.where(name: @benchmark.inputs.joins(:type).pluck(:'types.name').uniq)
    @games = @benchmark.games
    respond_to do |format|
      format.html {}
      format.js
      format.json { render :show, location: @benchmark }
    end
  end
  
  def new
    @benchmark = Bench.new
    @benches_game = BenchesGame.new
  end
  
  def edit
    @benchmark = Bench.friendly.find(params[:id])
    @benches_game = BenchesGame.new
    @benches_api = ApisBench.new
  end
  
  def create
    @benchmark = Bench.new(bench_params)
    respond_to do |format|
      if @benchmark.save
        @benchmark.update(slug: @benchmark.youtubeid)
        format.html { redirect_to @benchmark, notice: 'Benchmark was successfully created.' }
        format.json { render :show, status: :created, location: @benchmark }
        format.js
      else
        format.html { render :new }
        format.json { render json: @benchmark.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def update
  @benchmark = Bench.friendly.find(params[:id])
  respond_to do |format|
    if @benchmark.update(bench_params)
      @benchmark.update(slug: @benchmark.youtubeid)
      if params[:attachment]
        format.html { redirect_to edit_bench_path(@benchmark), flash: {success: 'Successfully uploaded'} }
      else
        format.html { redirect_to edit_bench_path(@benchmark), flash: {success: 'Successfully updated benchmark'} }
      end
      format.json { render :show, status: :ok, location: @benchmark }
      format.js
      if params[:attachment]
        if params[:file_type] == "CSV"
          @benchmark.parse_upload(params[:game_id], params[:variation_id], params[:type_id], @benchmark.id, params[:color], params[:api_id])
        end
        if params[:file_type] == "HML"
          @benchmark.parse_upload_hml(params[:game_id], params[:variation_id], params[:type_id], @benchmark.id, params[:color], params[:api_id])
        end
        if params[:file_type] == "MANGO"
          @benchmark.parse_upload_mango(params[:game_id], params[:variation_id], params[:type_id], @benchmark.id, params[:color], params[:api_id])
        end
        if params[:file_type] == "OCAT"
          @benchmark.parse_upload_ocat(params[:game_id], params[:variation_id], params[:type_id], @benchmark.id, params[:color], params[:api_id])
        end
      end
    else
      format.html { render :edit, flash: {warning: 'Failed to upload'} }
      format.json { render json: @benchmark.errors, status: :unprocessable_entity }
      format.js
    end
  end
end

  def recording
    @benchmark = Bench.friendly.find(params[:id])
  end
  
  def video_line
    @benchmark = Bench.friendly.find(params[:id])
    @types = Type.where(name: @benchmark.inputs.joins(:type).pluck(:'types.name').uniq)
    @games = @benchmark.games
  end
  
  def video_bar
    @benchmark = Bench.friendly.find(params[:id])
    @types = Type.where(name: @benchmark.inputs.joins(:type).pluck(:'types.name').uniq)
    @games = @benchmark.games
  end
  
  def delete_inputs
    @benchmark = Bench.friendly.find(params[:id])
    @benchmark.inputs.where(benches_game_id: params[:benches_game_id], type_id: params[:type]).delete_all
    Type.find(params[:type]).inputs.where(benches_game_id: params[:benches_game_id]).delete_all
    respond_to do |format|
      format.js
    end
  end

  def refresh
    @benchmark = Bench.friendly.find(params[:id])
    @benchmark.refresh_json
  end
  
  def delete_last_input
    @benchmark = Bench.friendly.find(params[:id])
    @benchmark.inputs.where(benches_game_id: params[:benches_game_id], type_id: params[:type]).last.delete
    respond_to do |format|
      format.js
    end
  end

  def delete_first_input
    @benchmark = Bench.friendly.find(params[:id])
    @benchmark.inputs.where(benches_game_id: params[:benches_game_id], type_id: params[:type]).first.delete
    respond_to do |format|
      format.js
    end
  end

  def totalbar
    @benchmark = Bench.friendly.find(params[:id])
    render json: @benchmark.totalbar
  end

  def total_cpu
    @benchmark = Bench.friendly.find(params[:id])
    render json: @benchmark.totalcpu
  end
  
  def video_total
    @benchmark = Bench.friendly.find(params[:id])
    @types = Type.where(name: @benchmark.inputs.joins(:type).pluck(:'types.name').uniq)
    @games = @benchmark.games
  end
  
  def publish
    @benchmark = Bench.friendly.find(params[:id])
    @benchmark.update(published: true)
    @benchmark.get_desc
  end
  
  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def bench_params
    params.require(:bench).permit(:name, :youtubeid, :upload)
  end
    
end
