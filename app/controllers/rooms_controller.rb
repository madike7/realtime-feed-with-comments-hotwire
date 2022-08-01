class RoomsController < ApplicationController
  include RoomsHelper
  include UsersHelper
  before_action :authenticate_user!
  before_action :set_activity_status
  before_action :only_admin, only: [:create, :destroy]
  before_action :set_room, only: [:destroy]

  MESSAGES_PER_ROOM_PAGE = 10

  def index
    @room = Room.new  # gia na dhmiourghsw neo room mesw tis formas
    
    # me to @rooms thelw na parw ola ta public rooms mesw tou scope sto model Room
    @rooms = Room.only_public_rooms.order('latest_message DESC')  # ta kanw sort me vash to time tou teleutaiou message
    
    # thelw na parw olous tous users ektos apo ton current_user mesw tou scope sto model User 
    @all_users = User.all_users_except(current_user)
    # anazhthsh gia users
    @users = user_search
    # online users
    @online_users = User.where.not(status: User.statuses[:offline]).count
    render 'index'
  end

  def show # Gia ta public (group) chats, thelw na paramenw stin idia selida kai na emfanizw to chat room sto plai
    # gia na ginei auto, vazw oles tis metablhtes tou index sto method show, kai etsi ginetai render kai to index page mazi
    
    # setting the chat_room, to xrhsimopoiw stin forma pou dhmiourgw ta messages gia to chat_room
    @chat_room = Room.find_by(id: params[:id])
    if @chat_room.nil?
      redirect_to rooms_path, alert: "Chatroom was not found" # ean exei diagrafei ena chatroom, kanw redirect
    else
      # opws kai sto index
      # akoma kai ton exw energo chat,
      # mporw na dw ola ta public rooms
      @rooms = Room.only_public_rooms.order('latest_message DESC')  # ta kanw sort me vash to time tou teleutaiou message

      @room = Room.new  # gia na dhmiourghsw neo room mesw tis formas
      
      @all_users = User.all_users_except(current_user) # lista me olous tous xrhstes ektos tou eautou mou
      @users = user_search  # anazhthsh gia users
      @online_users = User.where.not(status: User.statuses[:offline]).count # online users

      @message = Message.new # gia th dhmiourgia new message mesa sto chat room mesw tou partial /messages/_form

      #CURSOR BASED PAGINATION
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
      render 'index'  # kanw render to index action
    end
  end

  def create
    @room = Room.create(room_params)  # gia na kanw create ena room mesw tou partial _form
  end

  def search  # routes.rb , vazw search route, kanw post request wste na kanei respond me turbo_stream
    @users = user_search  

    respond_to do |format|
      format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("search_results",
            partial: "users/search_results",
            locals: { users: @users })
          ]
      end
    end
  end

  def destroy
    @room.destroy # diagrafh enos room
  end

  private

  def set_room  # pairnw to room gia to destroy action
    @room = Room.find(params[:id])
  end

  def only_admin  # mono enas admin mporei na kanei create h destroy ena room
    redirect_to root_path unless current_user.admin?
  end

  def room_params
    params.require(:room).permit(:name) # xreizomai mono to name
  end

  def set_activity_status # thetw to status tou user se online
    current_user.update!(status: User.statuses[:online]) if current_user
  end
end
