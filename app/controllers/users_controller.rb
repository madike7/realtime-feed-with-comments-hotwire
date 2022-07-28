class UsersController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_user
  POSTS_PER_PAGE = 6  # 6 user posts se kathe selida
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

  private

  def set_user
    @user = User.find_by(username: params[:username]) # thelw to param username apo kathe user, kai oxi to id.
    # thelw na vriskw to profil enos xrhsth mesw tou username tou.
    # localhost:3000/username
  end
end
