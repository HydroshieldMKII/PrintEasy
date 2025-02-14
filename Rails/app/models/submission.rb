class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :contest

  has_many_attached :files

  validates :name, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 200 }
  validate :files_presence

  private

  def files_presence_and_format
    if files.blank?
      errors.add(:files, "must be attached")
    else
      files.each do |file|
        unless file.blob.filename.to_s.downcase.end_with?('.stl')
          errors.add(:files, "must be an STL file")
        end
      end
    end
  end
end
