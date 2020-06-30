class CreateTopicVectorIndex < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :topics, :name_vector, using: :gin, algorithm: :concurrently
  end
end
