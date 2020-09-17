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