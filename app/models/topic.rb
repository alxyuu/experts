class Topic < ApplicationRecord
  belongs_to :member

  validates :name, presence: true
end
