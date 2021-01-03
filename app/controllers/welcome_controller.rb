class WelcomeController < ApplicationController
    def index
        if user_signed_in? && current_user.admin?
            @benchmarks = Bench.all
        else
            @benchmarks = Bench.all.where(published: true)
        end
        @user_benchmarks = Log.all
    end
end
