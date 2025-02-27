# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :country
  has_many :presets, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :printer_user, dependent: :destroy
  has_many :printers, through: :printer_user
  has_many :offers, through: :printer_user

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
    return unless profile_picture.attached?

    Rails.application.routes.url_helpers.rails_blob_url(profile_picture,
                                                        only_path: true)
  end
end
