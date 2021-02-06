class Game < ApplicationRecord
  has_and_belongs_to_many :benches
 
  validates :name, presence: true, allow_blank: false
  
  has_many :inputs, -> { distinct }, through: :benches
  has_many :types, -> { distinct }, through: :benches
  has_many :logs
end
