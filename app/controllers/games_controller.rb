class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :user_submissions, :game, :search, :user_benchmarks]
  def index
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true).where(source: 'mango').paginate(page: params[:page], per_page: 30)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def user_benchmarks
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true).where.not(source: 'mango').where(steam_type: nil).includes(:logs).paginate(page: params[:page], per_page: 30)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def games_logs
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def search
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def show
    @game = Game.find(params[:id])
    @logs = @game.logs
    @benchmarks = @game.benches.paginate(page: params[:page], per_page: 30)
  end
  
  def user_submissions
    @games = Game.all
  end
  
  def game
    @game = Game.find(params[:id])
    @benchmarks = Log.where(game_id: @game.id)
  end
end