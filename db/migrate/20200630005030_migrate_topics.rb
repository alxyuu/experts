class MigrateTopics < ActiveRecord::Migration[6.0]
  def up
    Member.where("topics != '[]'").find_each do |member|
      member.topics = member.read_attribute(:topics).map { |topic| Topic.new(name: topic) }
    end

    remove_column :members, :topics
  end

  def down
    add_column :members, :topics, :jsonb, index: { using: :gin }, null: false, default: []

    Member.joins(:topics).find_each do |member|
      member.update_columns(topics: member.topics.map(&:name))
    end
  end
end
