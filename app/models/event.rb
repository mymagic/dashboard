class Event < ActiveRecord::Base
  LOCATION_TYPES = {
    address: 'Address',
    skype: 'Name',
    phone: 'Number',
    other: 'Info'
  }.freeze

  # Behaviors
  include TimeInZone
  include NetworksConcern
  time_in_zone_for :starts_at, :ends_at

  # Associations
  belongs_to :creator, class_name: 'Member'
  belongs_to :network

  has_many :rsvps, dependent: :destroy
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

  has_and_belongs_to_many :networks

  # Validations
  validates :location_detail,
            :starts_at,
            :ends_at,
            :title,
            :time_zone,
            :creator,
            presence: true
  validates :location_type, inclusion: { in: LOCATION_TYPES.keys.map(&:to_s) }
  validates :networks, presence: true
  validate :ends_at_cannot_precede_starts_at,
           if: -> { ends_at.present? && starts_at.present? }

  # Scopes
  scope :upcoming, -> { where('ends_at > ?', Time.zone.now) }
  scope :past, -> { where('ends_at < ?', Time.zone.now) }
  scope :ordered, -> { order(starts_at: :asc) }
  scope :on_date, ->(date, time_zone) do
    where(
      'date(starts_at::TIMESTAMPTZ AT TIME ZONE :time_zone) = :date',
      time_zone: ActiveSupport::TimeZone::MAPPING[time_zone],
      date: date
    )
  end

  before_validation :override_timezone
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

  def community
    networks.first.community
  end

  private

  def create_activity
    networks.each do |network|
      Activity::EventCreating.create(owner: creator, event: self, network: network)
    end
  end

  def ends_at_cannot_precede_starts_at
    return if ends_at > starts_at
    errors.add(:ends_at, :cannot_precede_starts_at)
  end

  def override_timezone
    # TODO These conditions is temporary added to pass rspec Shoulda-matcher's method
    # `validate_presence_of` since it drops the attributes and breaks this callback
    if time_zone && starts_at && ends_at
      %w(starts_at ends_at).each do |attr|
        datetime = ActiveSupport::TimeZone.new(time_zone)
                                          .parse(attributes[attr].strftime('%F %T'))
        self.send(:"#{attr}=", datetime)
      end
    end
  end
end
