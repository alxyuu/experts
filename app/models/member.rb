class Member < ApplicationRecord
  has_and_belongs_to_many :friends, class_name: 'Member',
                                    join_table: :relationships,
                                    association_foreign_key: :to_id,
                                    foreign_key: :from_id,
                                    after_add: :ensure_bidirectional_relationship

  validates :short_url, format: URI::regexp(%w[http https]), if: :short_url?
  validates :website_url, format: URI::regexp(%w[http https])

  private

  def ensure_bidirectional_relationship(member)
    member.friends << self unless member.friends.where(id: self).exists?
  end
end
