class Input < ApplicationRecord
  belongs_to :type
  belongs_to :variation
  belongs_to :game
  belongs_to :bench
  belongs_to :api
end