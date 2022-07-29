class CreateRoommates < ActiveRecord::Migration[6.1]
  def change
    create_table :roommates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
