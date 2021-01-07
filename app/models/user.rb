class User < ApplicationRecord
  has_many :logs
  has_many :computers
  devise :database_authenticatable, #:registerable,
         :rememberable, :omniauthable, omniauth_providers: %i[discord]
  has_one_attached :profile
  
  def self.from_omniauth(auth)
    self.update_omniauth_user(auth)
    @user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      password = Devise.friendly_token[0, 20]
      user.email = auth.uid
      user.password = password
      user.password_confirmation = password
      user.username = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      user.admin = false
    end
    require 'open-uri'
    begin
      download = open(auth.info.image)
      User.first.profile.attach(io: download, filename: "profile.png")
    rescue OpenURI::HTTPError => ex
    end 
    return @user
  end
  
  def self.update_omniauth_user(auth)
    if User.where(provider: auth.provider, uid: auth.uid).any?
      User.where(provider: auth.provider, uid: auth.uid).last.update(username: auth.info.name, image: auth.info.image)
    end
  end

  
  def email_required?
    false
  end
end
