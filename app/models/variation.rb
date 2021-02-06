class Variation < ApplicationRecord
  has_many :inputs
  belongs_to :bench

  def to_s
    return name
  end
end
