class WelcomeController < ApplicationController
    def index
        @benchmarks = Bench.all.where(published: true)
        @user_benchmarks = Log.all
    end
end
