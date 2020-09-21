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
    def one_array
      array = []
      self.types.order(name: :desc).each do |type|
        array.push(type.onepercent(self))
      end
      return array
    end 

    def avg_array
      array = []
      self.types.order(name: :desc).each do |type|
        ##array.push(type.avg(self) - type.onepercent(self))
        array.push(type.avg(self))
      end
      return array
    end     
    
    def ninety_array
      array = []
      self.types.order(name: :desc).each do |type|
        #array.push(type.ninetyseven(self) - (type.onepercent(self) + (type.avg(self) - type.onepercent(self)) ))
        array.push(type.ninetyseven(self))
      end
      return array
    end

    def names
      self.types.order(name: :desc).pluck(:name)  
    end
end
