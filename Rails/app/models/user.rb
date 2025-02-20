class User < ApplicationRecord
  belongs_to :country
  has_many :presets, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :printer_users, dependent: :destroy

  has_one_attached :profile_picture

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  validates :username, presence: true, uniqueness: true
  validates :password_confirmation, presence: true
  validates :country_id, presence: true

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  def profile_picture_url
    Rails.application.routes.url_helpers.rails_blob_url(self.profile_picture, only_path: true) if self.profile_picture.attached?
  end
end
