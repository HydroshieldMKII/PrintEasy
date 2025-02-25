class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :contest

  has_one_attached :stl
  has_one_attached :image

  has_many :likes, dependent: :destroy

  validates :name, presence: true, length: { minimum: 3, maximum: 30 }
  validates :description, length: { maximum: 200 }
  validates :contest, presence: true
  validates :image, presence: true
  validates :stl, presence: true
 
  validate :stl_must_be_valid
  validate :image_must_be_valid

  def stl_url
    stl && url_for(stl)
  end

  def image_url
    image && url_for(image)
  end

  private

  def url_for(file)
    Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
  end

  def stl_must_be_valid
    return unless stl.attached?

    filename = stl.filename.to_s
    extension = File.extname(filename)

    unless extension.downcase == '.stl'
      errors.add(:stl, 'must have .stl extension')
    end
  end

  def image_must_be_valid
    return unless image.attached?

    unless image.content_type.in?(%w(image/png image/jpeg image/jpg))
      errors.add(:image, "must be a PNG, JPG, or JPEG file")
    end
  end
end