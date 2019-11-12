class Api < ApplicationRecord
  has_and_belongs_to_many :benches
  has_many :inputs
end
