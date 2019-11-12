class Type < ApplicationRecord
  has_many :variations
  has_many :inputs
  def to_s
    name.to_s
  end
end
