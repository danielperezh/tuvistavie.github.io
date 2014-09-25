# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  small_picture          :string(255)
#  large_picture          :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  nickname               :string(255)
#

class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile, :long_profile
  attr_accessible :small_picture, :large_picture, :first_name, :last_name, :nickname
  attr_accessible :work_place, :work_position, :work_url

  translates :profile, :long_profile

  def full_name
    [first_name, last_name].join(" ")
  end

end
