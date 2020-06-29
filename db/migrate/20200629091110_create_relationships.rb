class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.references :from, foreign_key: { to_table: :members }
      t.references :to, foreign_key: { to_table: :members }
      t.index [:from_id, :to_id], unique: true
    end
  end
end
