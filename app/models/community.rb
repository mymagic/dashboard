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
  validates :name, :slug, presence: true
  validates :name, :slug, uniqueness: true

  # Callbacks
  after_create :setup_administrator

  protected

  def setup_administrator
    members.create!(
      email: 'admin@example.com',
      password: 'passw0rd',
      role: 'administrator',
      time_zone: ActiveSupport::TimeZone[Time.zone.name],
      confirmed_at: DateTime.now
    )
  end
end
