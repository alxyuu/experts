class Member < ApplicationRecord
  has_many :relationships, foreign_key: :from_id
  has_many :friends, through: :relationships, source: :to, after_add: :ensure_bidirectional_relationship
  has_many :topics

  validates :short_url, format: URI::regexp(%w[http https]), if: :short_url?
  validates :website_url, format: URI::regexp(%w[http https])

  private

  def ensure_bidirectional_relationship(member)
    member.friends << self unless member.friends.where(id: self).exists?
  end
end
