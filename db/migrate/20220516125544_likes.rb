class Likes < ActiveRecord::Migration[6.1]
  def change
    rename_column :likes, :likeable_id, :post_id
    remove_column :likes, :likeable_type, :string
    #remove_index :likes, [:user_id, :likeable_id, :likeable_type]
    #remove_index :likes, [:likeable_id, :likeable_type]
  end
end
