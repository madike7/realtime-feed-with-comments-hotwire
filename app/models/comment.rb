class Comment < ApplicationRecord
  include ActionView::RecordIdentifier # gia na xrhsimopoiw to dom_id se ena model
  include ApplicationHelper

  belongs_to :post, counter_cache: true # kathe comment anhkei se ena post.
  belongs_to :user # kathe comment anhkei se ena user
  belongs_to :parent, class_name: 'Comment', optional: true # otan apantaw se ena comment, thelw na pairnw to comment_id sto opoio apantaw san parent_id
  # epeidh den yparxei class parent, prepei na orisw to class_name
  # 
  has_many :comments, foreign_key: :parent_id, dependent: :destroy # ena comment mporei na einai parent sta comments pou einai apanthseis se auto
  # xreiazomai to foreign_key wste na mporw na parw th lista me ta comments enos sygkekrimenou comment.
  # otan diagrafw ena parent comment, diagrafontai kai ola ta children tou

  validates :body, presence: true # prepei na mhn einai adeio

  # dokimh gia soft delete, antikatastash me "comment deleted" message anti gia diagrafh
  #def destroy
  #  update(deleted_at: Time.zone.now)
  #end

  #broadcast to neo comment se olous tous users
  after_create_commit do
    # to neo comment exei parent, to parent einai true, ara tha ginei prepend sto target dom_id(comment)_comments, dhladh katw apo to parent comment
    # alliws to kanw prepend stin koryfh ths listas twn comments pou den exoun parent, sto target dom_id(post)_comments, afou einai comment sto post kai oxi se allo comment
    
    broadcast_prepend_to [post, :comments], target: "#{dom_id(parent || post)}_comments", partial: "comments/comment_with_replies"
    update_com_counter
  end

  # broadcast update tou comment se olous tous users
  after_update_commit do
    broadcast_replace_to self
  end

  # broadcast th diagrafh tou comment se olous tous users
  after_destroy_commit do
    broadcast_remove_to self
    broadcast_action_to self, action: :remove, target: "#{dom_id(self)}_with_comments"
    if !post.nil?
      update_com_counter
    end
  end

  private

  # kanw broadcast to neo arithmo comments, gia kathe create h destroy.
  def update_com_counter
    broadcast_update_to("posts", target: "#{dom_id(post)}_comments_counter", html: post.comments_count) # target sto post partial, pou einai link_to post#show kai ananewnetai kai sto index kai sto show
    broadcast_update_to("posts", target: "comments_counter", html: post.comments_count) # target sto show tou post
  end
end
