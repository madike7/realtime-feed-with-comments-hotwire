class MessagesController < ApplicationController

  def create
    @message = current_user.messages.create(message_params) # kata th dhmiourgia pernaw san user ton current_user pou to stelnei

    unless @message.room.nil? #an to post exei diagrafei kai o user einai sto show h epixeirhsei na paei sto url tou, kanw redirect
      unless @message.save
        flash.now[:alert] = @message.errors.full_messages.join(', ')
        render turbo_stream:
          turbo_stream.prepend('flash', partial: 'shared/flash')
      end
    else
      redirect_to rooms_path, alert: "Chatroom was not found"
    end
  end

  def destroy # diagrafh enos message
    @message = Message.find(params[:id])
    # enas user mporei na diagrapsei mono ta mhnymata pou exei steilei o idios
    # enas admin mporei an diagrapsei ta mhnymata kai twn allwn xrhstwn
    if !current_user.admin? 
      if current_user != @message.user 
        redirect_to @message.room # an opoiosdhpote allos xrhsths peran tou message user epixeirhsei na diagrapsei message, ton kanw redirect
      else
        @message.destroy
      end
    else
      @message.destroy
    end
  end
  
  private

  def message_params
    params
      .require(:message)
      .permit(:body, recordings: [])  # pera apo to body, ena message mporei na exei kai attached recordings
      .merge(room_id: params[:room_id])  # opws kai sta comments
  end
end
