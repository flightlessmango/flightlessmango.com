class VariationsController < ApplicationController
    before_action :authenticate_user!

    def create
      @variation = Variation.new(variation_params)
      if @variation.save
        flash[:success] = "Type successfully created"
      else
        flash[:error] = "Type name can't be blank"
      end
      redirect_back(fallback_location: root_path)
    end

    def destroy
        @variation = Variation.find(params[:id])
        @variation.inputs.delete_all
        @variation.destroy
        redirect_to edit_bench_path(@variation.bench)
      end

    def variation_params
      params.require(:variation).permit(:name, :benches_game_id, :bench_id)
    end
  
  end