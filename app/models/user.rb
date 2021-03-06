require 'pp'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :feature_requests
  
  def stars
    github.rels[:starred].get.data
  end
         
  def repos
    github.rels[:repos].get.data
  end
  
  def github
    # Provide authentication credentials
    client = Octokit::Client.new :access_token => self.token
    # Fetch the current user
    client.user
  end
         
  def self.from_omniauth(auth)
   where(auth.slice(:provider, :uid)).first_or_create do |user|
     user.provider = auth.provider
     user.uid = auth.uid
     user.email = auth.info.email
     user.username = auth.info.nickname
     user.token = auth.credentials.token
   end
  end
  
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"]) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end    
  end
  
  def password_required?
    super && provider.blank?
  end
end
