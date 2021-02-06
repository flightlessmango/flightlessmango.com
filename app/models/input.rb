class Input < ApplicationRecord
  belongs_to :variation
  belongs_to :benches_game
  belongs_to :bench
end