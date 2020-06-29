class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.string :name, null: false
      t.string :website_url, null: false
      t.string :short_url
      t.jsonb :topics, null: false, default: [], index: { using: :gin }
    end
  end
end
