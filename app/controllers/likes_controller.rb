class LikesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!
  
  def show
    @post = Post.find(params[:post_id]) # get the post
    @like = Like.find_or_create_by(user: current_user, post: @post) # vriskw like tou current user se ena post kai an den yparxei to dhmiourgw
    @like.liked(params[:choice])  #kalw tin liked(choice) tou like.rb, analoga me to choice pou kalw stin link_to sto likes_link partial.
    # mono gia ton user pou kanei to like
    flash.now[:notice] = "Thanks for voting!"
    @like.render_flash_rating(@like.user, flash)  # emfanizw flash message mono ston user tou like
    @like.update_label(@like.user, params[:choice]) # kalw tin update label tou user pou kanei to like wste na emfanisw to katallhlo icon
  end
end
