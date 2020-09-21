if params[:type] == "total"
    json.data do
        json.array! ["AVG"] do | name |
            json.x @benchmark.type_avg
            json.y @benchmark.benches_games.first.names
            json.name name
            json.orientation 'h'
            json.marker do
                json.color @benchmark.type_colors
                json.width 1
            end
            json.type 'bar'
        end
    end
    json.layout do
        json.hovermode false
        json.responsive true
        #json.barmode 'stack'
        json.autosize  true
        json.modebar do
            json.orientation "h"
            json.bgcolor "222"
            json.color "white"
        end
        json.plot_bgcolor "rgba(1,1,1,0)"
        json.paper_bgcolor "rgba(1,1,1,0)"
        json.font do
            json.font 'lato, sans-serif'
            json.size 18
            if params[:size] == "mini"
                json.size 10
            else
                json.size 18
            end
            json.color '#E0E0E3'
        end
        json.xaxis do
            json.tickfont do
                json.color "#E0E0E3"
            end
            json.showgrid true
            json.zerolinecolor "#707073"
            json.zeroline true
            json.gridcolor "#707073"
        end
        json.margin do 
            json.l 150
        end
        json.height 400
    end
else
    json.array! @benchmark.games.order(id: :asc) do |game|
        json.game_name game.name
        benches_game = BenchesGame.where(game: game, bench: @benchmark).last
        json.types benches_game.types.order(id: :asc) do |type|
            json.type_name type.name
            json.inputs type.inputs.where(benches_game_id: benches_game.id).order(pos: :asc) do |input|
                json.fps input.fps
                json.frametime input.frametime
                json.gpu input.gpu
                json.cpu input.cpu
                json.elapsed input.pos
            end
        end
    end
end