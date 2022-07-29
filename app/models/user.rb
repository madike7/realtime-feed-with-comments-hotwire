class User < ApplicationRecord
  include ActionText::Attachable # sgid gia to action text
                                  # thelw na afairesw to html otan kanw save to mention sto database
                                  # otan kanw render to mention, to action text psaxnei gia to sgid pou afora ton user me to antistoixo id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # scope pou xrhsimopoiw ston controller wste na parw olous tous users ektos apo ton eauto mou
  scope :all_users_except, ->(user) { where.not(id: user)}
  # otan kanei register enas user ton prosthetw sti lista me tous users sto side bar tou chat
  after_create_commit { broadcast_append_to("users", partial: 'users/user', locals: { user: self, last_message: nil, room: nil }) }
  # se kathe allagi tou status tou user to kanw broadcast se olous, mesw tis broadcast_status_update pou orizw parakatw
  after_update_commit { broadcast_status_update }
  

  has_one_attached :avatar  # kathe user exei ena avatar
  has_many :posts # kathe user mporei na kanei polla post.
  has_many :comments  # kathe user mporei na kanei polla comments.
  has_many :messages # enas user exei polla chat messages
  has_many :likes, dependent: :destroy # kathe user mporei na kanei polla likes.
  validates :username, uniqueness: true, presence: true # username validation, prepei na einai monadiko
  
  has_many :notifications, as: :recipient, dependent: :destroy  # enas user exei polla notifications ws recipient, kai ean diagrafei diagrafontai k auta

  # o user mporei na einai eite aplos user eite admin
  enum role: %i[user admin].freeze, _default: 0
  #after_initialize :default_user_role, if: :new_record? # otan dhmiourgw ena user tou dinw role aplou 'user'

  # to status tou user sto chat mporei na einai online(einai sto page tou chat kai kanei actions), away(meta apo kapoia wra adraneias), offline(kleinei to tab tou chat H kanei logout)
  enum status: %i[offline away online]

  def broadcast_status_update
    #kanw replace to target user_activity_status tou partial activity_status pou provalei to status tou user
    # mesw tis status_color pou gia kathe case allazw to background color
    broadcast_replace_to 'user_activity_status', partial: 'users/activity_status', user: self
  end

  # xrhsimopoiw to enum status gia na metatrepsw to status se css
  def status_color # to kalw sto view gia na parw to css gia kathe status
    case status
    when 'online' # otan to status einai online, allazw to background se prasino mesw tou bootstrap class
      'bg-success'
    when 'away' # otan einai away,se kitrino
      'bg-warning'
    when 'offline'  # kai otan einai offline se mauro
      'bg-dark'
    else
      'bg-dark'
    end
  end

  def gravatar_url # gravatar from users email
    gravatar_id = Digest::MD5::hexdigest(email).downcase
    "https://gravatar.com/avatar/#{gravatar_id}.png"
  end
end
