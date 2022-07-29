class AddLatestMessageToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :latest_message, :datetime
  end
end
