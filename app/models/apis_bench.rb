class ApisBench < ApplicationRecord
  belongs_to :api
  belongs_to :bench
  has_many :inputs
  has_many :types, -> { distinct }, through: :inputs
end
