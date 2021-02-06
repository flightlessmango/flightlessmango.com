if @graph_type == "fps" || @graph_type == "frametime"
    json.array! @benches_game.variations.order(:name) do |type|
        if @size == "mini"
            @inputs = type.inputs.where(id: type.inputs.map {|input| input if input.id % 10 == 0 }).where(benches_game_id: @benches_game.id).order(:pos)
        else
            @inputs = type.inputs.where(benches_game_id: @benches_game.id).order(:pos)
        end
        json.name type.name
        json.color @inputs.last.color
        json.data do
            json.array! @inputs do |input| 
                json.set! "0", input.pos
                if @graph_type == "fps"
                    json.set! "1", input.fps
                else
                    json.set! "1", input.frametime
                end
            end
        end
    end
end

if @graph_type == "bar" || @graph_type == "totalbar"
    json.array! ["1%", "AVG", "97th"] do | name |
        json.name name
        json.data do
            json.array! @benches_game.variations.order(:name) do |type|
                if @graph_type == "totalbar"
                    typeInputs = @benchmark.inputs.where(variation_id: type.id)
                else
                    typeInputs = type.inputs.where(benches_game_id: @benches_game.id)
                end
                json.set! "0", type.name
                if name == "1%"
                    json.set! "1", typeInputs.where(id: typeInputs.order(fps: :asc).limit(typeInputs.count * 0.1)).average(:fps).round(1)
                end
                if name == "AVG"
                    json.set! "1", typeInputs.average(:fps).round(1)
                end
                if name == "97th"
                    json.set! "1", Bench.percentile(typeInputs.pluck(:fps).sort, 0.97).round(1)
                end
            end
        end
    end
end

if @graph_type == "cpu" || @graph_type == "gpu"
    array = []
    json.array! @benches_game.variations.order(:name) do |type|
        if @graph_type == "cpu"
            array.push([type.name, type.inputs.average(:cpu).round(1)])
        end
        if @graph_type == "gpu"
            array.push([type.name, type.inputs.average(:gpu).round(1)])
        end
    end
    json.merge! array
end