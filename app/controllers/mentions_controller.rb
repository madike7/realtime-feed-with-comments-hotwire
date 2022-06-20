class MentionsController < ApplicationController
  def index
    @users = User.all #mporw na kanw mention olous tous xrhstes

    respond_to do |format|
      format.json #user.json.jbuilder
    end
  end
end