class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user  # kathe message anhkei se ena user
  belongs_to :room  # kathe message anhkei se ena room
  # gia na apotrepsw allous xrhstes na stelnoun mhnymata se private rooms pou den symmetexoun ws roommates kalw tin before_create
  before_create :check_if_roommate
  # den thelw na stelnw empty messages
  validates :body, presence: true, unless: -> { recordings.present? } # epitrepw to body na einai empty, mono ean exw recording(s) attached sto file_field

  has_many_attached :recordings, dependent: :destroy  # gia na mporw na steilw video recording

  validate :validate_recording_types  # kanw validation ta recordings pou stelnw (san attachments), wste na mhn mporei kapoios na steilei kati pera apo video h audio files
  
  has_noticed_notifications model_name: 'Notification' # noticed gem gia ta notifications

  # me ti dhmiourgia enos message, to kanw broadcast sto chat room  (Append gia na mpei katw sti lista twn messages tou room)
  after_create_commit do 
    send_notification # stelnw notification ston paralhpth tou mhnymatos ean einai private room
    # set the time of the latest message
    update_room_with_latest_message # kanw update to room wste na mporw na ta kanw sort me vash to teleutaio message
    broadcast_append_later_to room # kanw broadcast append to message sto room pou anhkei
  end

  after_destroy_commit do
    update_notification_count
    # kanw update to latest_message field tou room
    update_room_with_latest_message  # wste ean to mhnyma tou diegrapsa htan to teleutaio tou room na kanei update to room sti lista me ta rooms me to neotero latest message tou (dhladh to prohgoumeno apo auto pou diegrapsa)
    broadcast_remove_to room  # otan diagrafw ena mhnyma kanw broadcast remove apo to room pou anhkei
  end
  
  # apo ton browser einai adynato kapoios user na steilei mhnyma se private room sto opoio den symmetexei(roommmate)
  # gia na apotrepsw omws na mporei na steilei kapoios 3os apo to rails console, kanw auto to extra check.
  def check_if_roommate
    return unless room.is_private # gia na kanw ton elegxo parakatw, elegxw an to room einai private
    # alliws oloi oi users mporoun na steiloun message se public room

    is_roommate = Roommate.where(user_id: self.user.id, room_id: self.room.id).first
    throw :abort unless is_roommate
  end

  def update_room_with_latest_message
    room.update(latest_message: Time.now) # kanw update tin wra sto latest_message column tou room meta apo kathe created message
  end

  private

  def validate_recording_types  # orizw poia file types epitrepetai na kanw upload mesw tou message form
    return unless recordings.attached?  # return an to message den periexei attached recordings

    acceptable_types = ["video/mp4", "video/webm", "video/quicktime", "video/mpeg", "audio/mpeg", "audio/mp4", "audio/webm", "audio/ogg", "audio/mp3", "audio/x-wav", "audio/wave", "audio/x-pn-wav"]

    recordings.each do |recording|  # gia kathe recording elegxw to content_type tou
      unless acceptable_types.include?(recording.content_type)  # an anevasw otidhpote allo, emfanizw to parakatw error
        errors.add(:recordings, 'can only be of type VIDEO: [webm, mp4, mpeg or quicktime] and AUDIO: [mp3, wav or ogg]')
      end
    end

  end

  def send_notification # otan exw ena private conversation me kapoion allo user, stelnw notification kathe fora pou tou stelnw neo mhnyma
    return unless room.is_private
    roommate = room.joined_roommates  # ena private conversation apoteleitai apo 2 users. pairnw tous users rou private room mesw tou joined_roommates pou exw orisei sto model tou Room 
    roommate.each do |user| # gia kathe user tou private room 
      next if user.eql?(self.user)  # den thelw na steilw notification ston current user, dhladh se auton pou stelnei to mhnyma alla mono ston recipient, opote kanw skip
      notification = MessageNotification.with(message: self, room:) # create a notification gia ton allo user o opoios einai o recipient tou mhnymatos, pernaw san message to idio to message kai san room to room tou message
      notification.deliver_later(user)  # to kanw deliver ston allo user
      broadcast_update_later_to(  # trigger ena turbo stream broadcast otan dhmiourgeitai ena message
        user, # gia na sigourepsw oti to notification tha paei mono ston user pou prepei na to dextei
        :notifications, # kanw set to broadcast channel sto user, :notifications KAI sto index page vazw ena turbo_stream_from current_user, :notifications
        target: "#{dom_id(user)}_#{dom_id(room)}_notifications",  # kanw update to notification counter sto target pou exw orisei sto partial _user_notifications
        partial: "users/notification_count",  # pernaw to partial pou thelw na kanw update ton counter
        locals: {
          count: room.notifications_as_room.where(type: MessageNotification.name, recipient: user).unread.count # pernaw ta locals, wste na allaksw to count twn unread notifications otan ena neo mhnyma stelnetai ston user
        }
      )
    end
  end

  def update_notification_count # opws kai sto send_notification
    # otan diagrafw ena message enos private room, ginetai destroyed kai to notification tou
    # gia na to kanw se real time, efoson enas user den to exei diavasei, kanw broadcast update ton arithmo twn unread notifications tou recipient tou message
    return unless room.is_private
    roommate = room.joined_roommates  
    roommate.each do |user|
      next if user.eql?(self.user)
      broadcast_update_to(
        user,
        :notifications,
        target: "#{dom_id(user)}_#{dom_id(room)}_notifications",
        partial: "users/notification_count",
        locals: {
          count: room.notifications_as_room.where(type: MessageNotification.name, recipient: user).unread.count # pernaw ta locals, wste na allaksw to count twn unread notifications otan ena neo mhnyma stelnetai ston user
        }
      )
    end
  end
end
