class Post < ApplicationRecord
  include ActionView::RecordIdentifier # gia na xrhsimopoiw to dom_id se ena model
  include ApplicationHelper

  belongs_to :user # kathe post anhkei se ena user
  has_many :comments, dependent: :destroy # ena post exei polla comments, otan diagrafw to post diagrafontai kai auta
  has_many :likes, dependent: :destroy # ena post exei polla likes, otan diagrafw to post diagrafontai kai auta

  #rich text field
  has_rich_text :body
  validates :body, presence: true #den prepei na einai keno
 
  # SEARCH SCOPES

  # search_text scopepou kanei join sto ActionText::RichText model, kanontas ena ILIKE keyword query
  # To ILIKE den ypologizei gia HTML characters, px an psaksw gia mia ekfrash kai mia apo tis lekseis ths sto body tou post einai mesa se <strong>leksh</strong> 
  # den tha kanei match me to content
  # Gia to logo auto, prosthetw ena plain_text_body column sto action_text_rich_texts table, wste ta ActionText::RichText models na grafoun kai na kanoun search se auto.
  # orizw ena callback before_save, opou se kathe create h update tou Post kalw tin to_plain_text, pou afairei kathe HTML syntax kai afhnei mono to text content tou body sto plain_text_body.
  # Gia na mhn einai periorismeno mono sto Post model, kai na exw th dunatothta gia full text search se ola ta models me rich_rext_content kanw to ekshs:
  # config/initializers/action_text_rich_text.rb
  scope :search_text, ->(query) { joins(:rich_text_body).merge(ActionText::RichText.with_body_containing(query)) }
  # search_username scope, psaxnw stous users gia matching username me to query gia na epistrepsw ola ta posts tou user pou psaxnw
  scope :search_username, ->(username) { joins(:user).where('users.username LIKE ?', "%#{username}%") }


  #Broadcast

  # gia to broadcast xreiazomai sto index view:
  # ena turbo_stream_from :posts
  # ena default target <div id="posts">
  # ena default partial 'posts/_post'
  # etsi mporw na kanw broadcast kathe create update kai destroy record

  # add on top of DOM ID
  # target: HTML element with an ID DOM ID, <div id="posts">
  # to HTML tou created post ginetai broadcasted se olous tous xrhstes pou einai subscrribed to stream :posts
  # kai prostithetai panw (prepend) apo ti lista me ola ta posts.
  after_create_commit do 
    broadcast_prepend_to :posts, target: "posts", partial: "posts/post_to_broadcast", locals: {  post: self } 
    update_post_counter
  end
  
  # Gia na kanw broadcast to updated post se olous tous users pou einai subscribed sto stream.
  # O logos pou den to kanw einai giati den exw vrei tropo na elegxw an o kathe user exei kanei hdh like sto post,
  # logw tou oti den mporw na xrhsimopoihsw to current_user tou devise me to broadcast.
  # etsi to partial post_to_broadcast to xrhsimopoiw mono se kathe create opou kanenas user den exei kanei akomh like sto post.
  # opote to icon gia to like tha einai to default gia ena neo post (like_icon)

  # Stin update tou post controller, kanw replace to post mono gia ton user pou to kanei edit se real time, 
  # mesw tou turbo_stream.replace @post, kai etsi pairnw to swsto like icon tou current_user

  #after_update_commit do 
  #  broadcast_update_to :posts, partial: "posts/post_to_broadcast", locals: { post: self }
  #end

  # destroy to post 
  after_destroy_commit do 
    broadcast_remove_to :posts, target: self # afairei to post apo ti lista me ta post gia olous tous xrhstes
    update_post_counter
  end 

  #ypologizw ta like tou post analoga me to choice tou kathe like
  def like_count
    likes.sum(:choice)
  end

  private 

  #update ton post_counter se olous tous xrhstes, otan dhmiourgeitai h diagrafetai post.
  #exw ena id='post_counter' sto index view pou ginetai update meta apo kathe create kai destroy
  def update_post_counter
    broadcast_update_to :posts, target: "post_counter", partial: 'posts/count', locals: { count: Post.count }
  end
end
