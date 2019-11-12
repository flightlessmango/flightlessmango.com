class Computer < ApplicationRecord
  belongs_to :log
  belongs_to :user
end
