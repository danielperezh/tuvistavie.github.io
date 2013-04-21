class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile, :long_profile
  attr_accessible :small_picture, :large_picture, :first_name, :last_name, :nickname

  translates :profile, :long_profile

  def full_name
    [first_name, last_name].join(" ")
  end
end
