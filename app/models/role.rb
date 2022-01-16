class Role < ApplicationRecord
  validates :name, presence: true
  validates :person, presence: true
end
