class Game < ApplicationRecord
  has_and_belongs_to_many :benches
  has_many :inputs
  has_many :types, -> { distinct }, through: :inputs
  has_many :logs
end
