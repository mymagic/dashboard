class Event < ActiveRecord::Base
  LOCATION_TYPES = %w( Address Skype Phone Other )

  # Associations
  belongs_to :creator, class_name: 'Member'
  belongs_to :community

  # Validations
  before_validation :set_community, if: -> { creator.present? }
  validates :location_detail,
            :starts_at,
            :ends_at,
            :title,
            :time_zone,
            :creator,
            presence: true
  validates :location_type, inclusion: { in: LOCATION_TYPES }
  validate :ends_at_cannot_precede_starts_at,
           if: -> { ends_at.present? && starts_at.present? }

  # Scopes
  scope :upcoming, -> { where('ends_at > ?', Time.now) }
  scope :past, -> { where('ends_at < ?', Time.now) }

  def to_param
    "#{ id }-#{ title.parameterize }"
  end

  def at_address?
    location_type == 'Address'
  end

  private

  def set_community
    self.community = creator.community
  end

  def ends_at_cannot_precede_starts_at
    return if ends_at > starts_at
    errors.add(:ends_at, :cannot_precede_starts_at)
  end
end
