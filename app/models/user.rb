class User < ApplicationRecord
  include ActionText::Attachable # sgid gia to action text
                                  # thelw na afairesw to html otan kanw save to mention sto database
                                  # otan kanw render to mention, to action text psaxnei gia to sgid pou afora ton user me to antistoixo id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar  # kathe user exei ena avatar
  has_many :posts # kathe user mporei na kanei polla post.
  has_many :comments  # kathe user mporei na kanei polla comments.

  has_many :likes, dependent: :destroy # kathe user mporei na kanei polla likes.
         

  validates :username, uniqueness: true, presence: true # username validation, prepei na einai monadiko
  
  def gravatar_url # gravatar from users email
    gravatar_id = Digest::MD5::hexdigest(email).downcase
    "https://gravatar.com/avatar/#{gravatar_id}.png"
  end
end
