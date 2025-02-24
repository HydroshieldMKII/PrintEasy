class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :contest

  has_many_attached :files
  has_many :likes, dependent: :destroy

  validates :name, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 200 }
  validates :contest, presence: true
  validates :files, presence: true
  validate :files_presence_and_format

  def stl_url
    files[0] && url_for(files[0])
  end

  def image_url
    files[1] && url_for(files[1])
  end

  private

  def url_for(file)
    Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
  end

  def files_presence_and_format
    if files.blank? || files.count < 1
      errors.add(:files, "must have at least one attached file (STL)")
    else
      if files.count > 2
        errors.add(:files, "must have at most two attached files")
      end
      
      stl_file = files[0]
      unless stl_file.blob.filename.to_s.downcase.end_with?('.stl')
        errors.add(:files, "first file must be an STL file")
      end

      if files.count > 1
        image_file = files[1]
        unless image_file.blob.filename.to_s.downcase.match?(/\.(jpg|jpeg|png)$/)
          errors.add(:files, "second file must be an image (JPG, JPEG, or PNG)")
        end
      end
    end
  end
end