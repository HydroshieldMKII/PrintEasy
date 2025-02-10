class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  validates :username, presence: true, uniqueness: true

  def validates_confirmation_of_password
    errors.add(:password, "confirmation doesn't match Password") if password != password_confirmation
    debugger
  end
end
