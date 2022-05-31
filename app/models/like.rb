class Like < ApplicationRecord
  include ActionView::RecordIdentifier
  include ApplicationHelper

  belongs_to :user  #kathe like anhkei se ena user
  belongs_to :post  #kathe like anhkei se ena post
  enum choice: { upvote: 1, downvote: -1, cancel: 0 } #epiloges twn likes

  def liked(choice) #kaleitai sto show tou likes_controller
    return unless choice.in?(Like::choices.keys)

    # ! updates the enum value
    # ? checks if choice is 
    case choice
    when 'upvote' # an o user kanei like xwris na exei ksanakanei, to enum choice ginetai 1, alliws 0.
      upvote? ? cancel! : upvote! # an exei hdh kanei like, dhladh to choice einai 1, kai kanei upvote, to condition einai true, ara to enum choice ginetai 0 (cancel)
    when 'downvote'
      downvote? ? cancel! : downvote!
    end
  end

  #kanw update to like_counter se olous tous xrhstes
  after_update_commit do
    broadcast_update_to("posts", target: "#{dom_id(post)}_count", html: post.like_count)
  end

  #meta to like emfanizw to flash ston current_user pou ekane to like
  def render_flash_rating(user, flash)
    broadcast_prepend_to([user, :posts], target: :flash, partial: 'shared/flash', locals: { flash: flash })
  end

  # otan o user kanei like, kanw broadcast to neo icon mono sto idio (current_user)
  # gia to logo auto exw sto index dyo streams, wste sto stream pou pernaw to current_user, na allazw to icon tou like antistoixa
  # me ton tropo auto to icon allazei mono ston ekastote user kai oxi stous upoloipous
  def update_label(user, choice)  #kaleitai ston likes_controller
    label_icon = choice == 'upvote' ? like_icon : dislike_icon #egw kanw mono upvote opote tha exw panta true kai to icon tha einai to like_icon
    new_label = set_label(self.post, choice, label_icon, user) #application_helper
    broadcast_update_to([user, :posts], target: "#{dom_id(post)}_#{choice}_label", html: new_label) #kanei broadcast mono ston current_user pou kanei to like kai allazei to icon.
  end
end