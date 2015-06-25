class Event < ActiveRecord::Base
  LOCATION_TYPES = {
    address: 'Address',
    skype: 'Name',
    phone: 'Number',
    other: 'Info'
  }.freeze

  # Behaviors
  include TimeInZone
  time_in_zone_for :starts_at, :ends_at

  # Associations
  belongs_to :creator, class_name: 'Member'
  belongs_to :community

  has_many :rsvps
  has_many :members, through: :rsvps do
    def attending
      where(rsvps: { state: 'attending' })
    end

    def maybe_attending
      where(rsvps: { state: 'maybe_attending' })
    end

    def not_attending
      where(rsvps: { state: 'not_attending' })
    end
  end

  has_many :activities,
           as: :resource,
           dependent: :destroy

  # Validations
  before_validation :set_community, if: -> { creator.present? }
  validates :location_detail,
            :starts_at,
            :ends_at,
            :title,
            :time_zone,
            :creator,
            presence: true
  validates :location_type, inclusion: { in: LOCATION_TYPES.keys.map(&:to_s) }
  validate :ends_at_cannot_precede_starts_at,
           if: -> { ends_at.present? && starts_at.present? }

  # Scopes
  scope :upcoming, -> { where('ends_at > ?', Time.zone.now) }
  scope :past, -> { where('ends_at < ?', Time.zone.now) }
  scope :ordered, -> { order(starts_at: :asc) }

  after_create :create_activity

  def to_param
    "#{ id }-#{ title.parameterize }"
  end

  def location_coordinates
    "#{ location_latitude },#{ location_longitude }"
  end

  def at_address?
    location_type == 'address'
  end

  def ended?
    ends_at < Time.zone.now
  end

  private

  def create_activity
    Activity::EventCreating.create(owner: creator, event: self)
  end

  def set_community
    self.community = creator.community
  end

  def ends_at_cannot_precede_starts_at
    return if ends_at > starts_at
    errors.add(:ends_at, :cannot_precede_starts_at)
  end
end
