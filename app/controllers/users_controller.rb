class UsersController < ApplicationController
  include ActionView::RecordIdentifier
  include RoomsHelper
  include UsersHelper
  before_action :set_user, only: [:profile]
  POSTS_PER_PAGE = 6  # 6 user posts se kathe selida
  MESSAGES_PER_ROOM_PAGE = 10

  def profile
    @user.update(views: @user.views + 1)  # kathe fora pou vlepei kapoios to profile tou xrhsth auksanw to view count
    #cursor based pagination gia ta posts tou user, opws ston posts controller
    @cursor = params[:cursor]
    @posts = @user.posts
                  .where(@cursor ? ["id < ?", @cursor] : nil) # to epomeno post na exei mikrotero id apo to id tou cursor
                  .includes(:rich_text_body)
                  .order(id: :desc)                           # ola ta posts kata fthinousa seira
                  .take(POSTS_PER_PAGE)                       # kathe fora thelw na ginontai return POSTS_PER_PAGE (px. 5) posts
    
    @next_cursor = @posts.last&.id  # thetw next_cursor to teletaio post tis listas
    @more_pages = @next_cursor.present? && @posts.count == POSTS_PER_PAGE
    render "users/profile_scrollable_list" if params[:cursor]
  end

  def show  # Gia ta private chats, thelw na paramenw stin idia selida kai na emfanizw to chat room sto plai
    # gia na ginei auto, vazw oles tis metablhtes tou RoomsController#index sto method show, kai etsi ginetai render kai to index page mazi
    # orizw ta @user, @users, kai @all_users
    @user = User.find(params[:id]) # o user me ton opoio kanw private chat, to xrhsimopoiw kai san to onoma tou private room
    #@users = User.all_users_except(current_user) # olous ektos tou current user
    @all_users = User.all_users_except(current_user)

    # gia tin anazhthsh xrhstwn, an den exw anazhthsei kati, provalw ena empty list.
    # alliws provallw ta results tis anazitisis
    @users = user_search # helper method pou exw dhmiourghsei sto users_helper.rb

    # gia na deiksw posoi users einai online, thewrw online autous pou to status tous den einai offline. (einai online h away)
    @online_users = User.where.not(status: User.statuses[:offline]).count

    @rooms = Room.only_public_rooms.order('latest_message DESC')  # ta kanw sort me vash to time tou teleutaiou message
    @room = Room.new

    @message = Message.new
    
    # orizw ena onoma gia kathe private room mesw tis get_private_name pou orizw parakatw  
    @private_room_name = get_private_name(@user, current_user)
    # elegxos an yparxei hdh to private room (mesw tou @private_room_name)
    # an yparxei allazw tin metablhth @chat_room se auto, alliws to dhmiourgw mesw tis create_private_conversion pou exw orisei sto model Room
    @chat_room = Room.where(name: @private_room_name).first || Room.create_private_conversation([@user, current_user], @private_room_name)

    # CURSOR BASED PAGINATION
    @cursor = params[:cursor]
    @messages = @chat_room.messages
                                   .where(@cursor ? ["id < ?", @cursor] : nil)
                                   .includes(:user)
                                   .order(id: :desc)
                                   .take(MESSAGES_PER_ROOM_PAGE)
                                   .reverse  #kanw reverse ti lista me ta messages, giati thelw to neotero na einai sto bottom kai na kanw scroll up gia na dw ta epomena (palaiotera)
    @next_cursor = @messages.reverse.last&.id  # thelw na valw ton cursor sto teleutaio message tis listas, alla epeidh thn exw hdh kanei reverse, prepei na tin ksanakanw gia paraw to id tou palaioterou message 
    @more_pages = @next_cursor.present? && @messages.count == MESSAGES_PER_ROOM_PAGE
    render 'messages/scrollable_message_list' and return if params[:cursor]

    mark_notifications_as_read  # otan mpainw sto show page enos private chat, kanw update ta unread notifications se read
    render 'rooms/index' # gia na paramenw stin idia selida 
  end

  def mark_notifications_as_read  # otan kanw click se ena private conversation, thelw an yparxoun notification na fainetai oti diabasthkan
    notifications = @chat_room.notifications_as_room.where(recipient: current_user).unread  # pairnw ta notification tou private chat opou recipient einai o current_user
    if notifications.any?
      notifications.update_all(read_at: Time.zone.now)  # update ola se read
    end
  end

  private

  def set_user
    @user = User.find_by(username: params[:username]) # thelw to param username apo kathe user, kai oxi to id.
    # thelw na vriskw to profil enos xrhsth mesw tou username tou.
    # localhost:3000/username
  end
end
