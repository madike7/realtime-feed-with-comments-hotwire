module RoomsHelper
  def get_private_name(other_user, user) #dhmiourgw ena unique name gia to private room metaksy twn dyo users me vash ta id tous
    user = [other_user, user].sort
    "private_room_#{user[0].id}_#{user[1].id}"
  end
end
