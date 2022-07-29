class Room < ApplicationRecord
  include ActionView::RecordIdentifier
  #validates_uniqueness_of :name # kathe room exei unique name
  validates :name, presence: true, uniqueness: true
  scope :only_public_rooms, -> { where(is_private: false) } # scope gia na parw ta rooms pou den einai private conversations
  # otan dhmiourgw ena room to kanw broadcast (append) stin lista me ta rooms tou sidebar, efoson den einai private conversation
  after_create_commit { broadcast_append_to("rooms", partial: 'rooms/room', locals: { user: nil, last_message: nil }) unless self.is_private }

  # otan ginetai update ena room (otan allazei to latest_message time, afou prostithetai neo mhnyma sto room)
  # kanw broadcast to teleutaio mhnyma tou room se olous
  after_update_commit { broadcast_latest_message }

  after_destroy_commit { broadcast_remove_to :rooms unless self.is_private } # otan o admin diagrapsei ena public room, kanw broadcast remove gia olous

  has_many :messages, dependent: :destroy  #kathe room exei polla messages

  # gia ta private rooms
  has_many :roommates, dependent: :destroy
  # oi users enos private room (private conversation)
  has_many :joined_roommates, through: :roommates, source: :user # mesw tou table roommates me model User

  # kanw convert to room se notifications, wste na mporw na xrhsimopoihsw to notifications_as_room gia na parw ta unread notifications tou room
  has_noticed_notifications model_name: 'Notification'  #when a room is destroyed, any related notifications are destroyed too.

  # update to teletaio message katw apo to onoma tou room sti lista twn public rooms
  def broadcast_latest_message
    last_message = room_latest_message  # vazw sti metabliti last_message , to neotero message mesw tis room_latest_message pou orizw parakatw
    #return unless last_message  # elegxw oti den einai nil
    
    if last_message.nil?  # an diagrapsw to teleutaio message se ena room, allazw to latest_message view wste na mhn emfanizei kapoio message
      unless self.is_private
        # gia ta public rooms
        broadcast_update_to("rooms", # to channel
                            target: "room_#{id} last_public_message", # to div pou kanw target sto partial
                            partial: "rooms/latest_message", 
                            locals: { user: nil, last_message: nil }
        )
      else
        # gia to private chat me allo user
        broadcast_update_to("users", 
                            target: "room_#{id} last_private_message", 
                            partial: "users/latest_message", 
                            locals: { room: self, user: nil, last_message: nil }
        )

        # gia na enhmerwnw kai ta search results gia ta private rooms
        broadcast_update_to("users", 
                            target: "room_#{id} search_last_private_message", 
                            partial: "users/latest_message", 
                            locals: { room: self, user: nil, last_message: nil }
        )
      end
    else
      unless self.is_private
        # gia ta public rooms
        broadcast_update_to("rooms", # to channel
                            target: "room_#{id} last_public_message", # to div pou kanw target sto partial
                            partial: "rooms/latest_message", 
                            locals: { room: self, user: last_message.user, last_message: last_message }
        )
      else
        # gia to private chat me allo user
        broadcast_update_to("users", 
                            target: "room_#{id} last_private_message", 
                            partial: "users/latest_message", 
                            locals: { room: self, user: last_message.user, last_message: last_message }
        )

        # gia na enhmerwnw kai ta search results gia ta private rooms
        broadcast_update_to("users", 
                            target: "room_#{id} search_last_private_message", 
                            partial: "users/latest_message", 
                            locals: { room: self, user: last_message.user, last_message: last_message }
        )
      end
    end
  end

  # ean den yparxei to private room metaksy twn dyo users, to dhmiourgw
  def self.create_private_conversation(users, private_room_name) # h metavlhth users periexei lista me tous 2 users pou anhkoun sto private room
    chat_room = Room.create(name: private_room_name, is_private: true) # to onoma tou room to pairnw apo tin metablhth @private_room_name tou users controller
    # thetw to boolean is_private true, afou to room einai private metaksy twn 2 users
    users.each do |user|  # gia kathe user tis lista users pou pernaw sti methodo auth, dhmiourgw enan Roommate, me user_id to id tou user kai room_id to private room pou dhmiourghsa 
      Roommate.create(user_id: user.id, room_id: chat_room.id)
    end
    chat_room # apo tin klhsh tis methodou epistrefw to chat_room, to opoio tha einai to @chat_room sto users controller
  end

  # elegxw an o user einai roommate sto private room, kaleitai sto _user partial gia na elegksw an exw active private chat 
  def roommate?(room, user)
    room.roommates.where(user: user).exists?
  end

  def room_latest_message # method pou epistrefei to teleutaio mhnyma tou room, wste na to emfanisw katw apo to onoma tou room sti lista me ta public rooms
    if messages.any?
      messages.includes(:user).order(created_at: :desc).first # pernaw sto room_latest_message to teleutaio message tou room kanontas order descending kai pairnontas to prwto mesw tou first
    else
      nil 
    end
  end
end
