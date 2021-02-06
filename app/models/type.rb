class Type < ApplicationRecord
  has_many :variations
  has_many :inputs
  belongs_to :bench
  belongs_to :benches_game
  
  def to_s
    name.to_s
  end

  # def onepercent(benches_game)
  #   typeInputs = self.inputs.where(benches_game_id: benches_game.id)
  #   pluck = typeInputs.where(id: typeInputs.order(fps: :asc).limit(typeInputs.count * 0.1)).pluck(:id)
  #   onepercent = typeInputs.where(id: pluck).average(:fps)
  #   return onepercent.to_i
  # end

  # def ninetyseven(benches_game)
  #   typeInputs = self.inputs.where(benches_game_id: benches_game.id)
  #   return Bench.percentile(typeInputs.pluck(:fps).sort, 0.97).round(0)
  # end

  # def avg(benches_game)
  #   typeInputs = self.inputs.where(benches_game_id: benches_game.id)
  #   return typeInputs.average(:fps).to_i
  # end

end