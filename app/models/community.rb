class Community < ActiveRecord::Base
  # Concerns
  extend FriendlyId

  # Behaviors
  friendly_id :name, use: :slugged
  mount_uploader :logo, LogoUploader

  # Associations
  has_many :companies, dependent: :destroy
  has_many :members,   dependent: :destroy

  # Validations
  validates :name, :slug, :logo, presence: true
  validates :name, :slug, uniqueness: true
end
