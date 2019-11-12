class Variation < ApplicationRecord
  has_many :inputs
  belongs_to :type
end
