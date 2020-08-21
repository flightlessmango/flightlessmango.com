json.array! @benchmark.types do |type|
    json.type_name type.name
    json.inputs type.inputs.where(bench: @benchmark).order(pos: :asc) do |input|
        json.fps input.fps
        json.frametime input.frametime
        json.gpu input.gpu
        json.cpu input.cpu
        json.elapsed input.pos
    end
end