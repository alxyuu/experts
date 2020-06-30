class CreateTopics < ActiveRecord::Migration[6.0]
  def up
    create_table :topics do |t|
      t.references :member, null: false
      t.string :name, null: false
    end

    execute <<-SQL
      ALTER TABLE topics ADD COLUMN name_vector tsvector GENERATED ALWAYS AS (
        to_tsvector('english', name)
      ) STORED;
    SQL
  end

  def down
    drop_table :topics
  end
end
