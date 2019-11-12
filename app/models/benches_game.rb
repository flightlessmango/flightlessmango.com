class BenchesGame < ApplicationRecord
  belongs_to :game
  belongs_to :bench
  has_many :inputs
  has_many :types, -> { distinct }, through: :inputs
  
  def stackedChart(game)
    data = [
            {
              name: 'Max',
              data: game.inputs.where(bench_id: self.bench_id).joins(:type).order('types.name').group('types.name').maximum(:fps),
            },
            {
              name: 'Avg',
              data: game.inputs.where(bench_id: self.bench_id).joins(:type).group('types.name').average(:fps),
            },
            {
              name: 'Min',
              data: game.inputs.where(bench_id: self.bench_id).joins(:type).group('types.name').minimum(:fps),
            }
          ]
    end
    
end
