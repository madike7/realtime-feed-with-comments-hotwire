module ApplicationHelper
  include Pagy::Frontend

  def render_flash_messages  #helper gia na kanw prepend ta flash messages sto id flash tou application view
    turbo_stream.prepend "flash", partial: "shared/flash"
  end

  def set_label(post, action, icon, user)
    like = post.likes.find_by(user_id: user&.id) # vriskw an yparxei like tou user sto post
    like&.choice == action ? undo_like_icon : icon # an den exei kanei like, to condition einai false, kai tha emfanizei to like_icon
                                                  # an yparxei like tou user, kai to choice einai 1 (upvote), tote to condition einai true kai emfanizei to undo_like_icon
                                                  # an exei ksanapathsei sto like, gia na to allaksei, to choice einai 0(cancel), ara to condition false, kai emfanizei to like_icon
  end

  # otan kanw broadcast to _post_to_broadcast partial, exw static true, wste panta to icon na einai to like_icon (den exei kanei like o user) se ena neo post.
  # sto partial _post exw static nil, wste na kalw thn set_label, h opoia kathorizei to swsto icon analoga me to choice tou like tou current_user.
  def like_label(post, static) 
    static ? like_icon : set_label(post, 'upvote', like_icon, current_user)
  end

  #def dislike_label(post, static)
  #  static ? dislike_icon : set_label(post, 'downvote', dislike_icon, current_user)
  #end

  def like_icon
    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-heart" viewBox="0 0 16 16">
      <path d="m8 2.748-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.886.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748zM8 15C-7.333 4.868 3.279-3.04 7.824 1.143c.06.055.119.112.176.171a3.12 3.12 0 0 1 .176-.17C12.72-3.042 23.333 4.867 8 15z"/>
    </svg>'.html_safe
  end

  #def dislike_icon
  #  '<svg xmlns="http://www.w3.org/2000/svg" heigh="24px" width="24px" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  #    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14H5.236a2 2 0 01-1.789-2.894l3.5-7A2 2 0 018.736 3h4.018a2 2 0 01.485.06l3.76.94m-7 10v5a2 2 0 002 2h.096c.5 0 .905-.405.905-.904 0-.715.211-1.413.608-2.008L17 13V4m-7 10h2m5-10h2a2 2 0 012 2v6a2 2 0 01-2 2h-2.5" />
  #  </svg>'.html_safe
  #end

  def undo_like_icon
    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#da0101" class="bi bi-heart-fill" viewBox="0 0 16 16">
      <path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/>
    </svg>'.html_safe
  end  
end