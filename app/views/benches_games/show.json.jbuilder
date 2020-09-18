json.data @benches_game.types.order(:name) do |type|
    json.line do
        json.color type.inputs.last.color
    end
    json.mode "lines"
    json.name type.name
    @inputs = []
    if params[:size] == "full"
        @inputs = type.inputs.where(benches_game_id: @benches_game.id).order(:pos)
    else
        @inputs = type.inputs.where(benches_game_id: @benches_game.id).order(:pos).map {|input| input if input.id.to_i % 50 == 0 }.compact
    end
    json.x @inputs.pluck(:pos)
    if @graph_type == "fps"
        json.y @inputs.pluck(:fps)
    else
        json.y @inputs.pluck(:frametime)
    end
end
json.layout do
    json.margin do 
        json.r 50
        json.t 40
        json.l 50
    end
    json.modebar do
        json.orientation "h"
        json.bgcolor "222"
        json.color "white"
    end
    json.title do
        json.text @graph_type.upcase!
        json.xanchor "center"
    end
    json.hovermode false
    json.responsive true
    json.legend do
        json.xanchor "center"
        json.x 0.5
        json.y -0.2
        json.yanchor "bottom"
        json.orientation "h"
    end
    json.font do
        json.font 'lato, sans-serif'
        if params[:size] == "mini"
            json.size 10
        end
        json.color '#E0E0E3'
    end
    json.plot_bgcolor "rgba(1,1,1,0)"
    json.paper_bgcolor "rgba(1,1,1,0)"
    json.xaxis do
        json.showgrid false
        json.autotick true
        json.ticks ""
        json.showticklabels false
    end
    json.yaxis do
        if params[:graph_type] == "FPS"
            json.range [@benches_game.min, @benches_game.max]
        else
            json.range [0, 1000 / @benches_game.min]
        end
        json.tickfont do
            json.color "#E0E0E3"
        end
        json.showgrid true
        json.zerolinecolor "#707073"
        json.zeroline true
        json.gridcolor "#707073"
    end
end