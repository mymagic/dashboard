class Company < ActiveRecord::Base
  include SocialMediaLinkable

  FILTERS = %i(portfolio mine).freeze

  paginates_per 24

  mount_uploader :logo, LogoUploader

  validates :name, :community, presence: true
  validates :logo, presence: true, on: :update
  validates :description, length: { minimum: 5 }, allow_blank: true
  validates(
    :website,
    format: {
      with: URI::regexp(%w(http https)),
      message: 'is not a valid URL'
    },
    allow_blank: true)

  # Associations
  belongs_to :community

  scope :ordered, -> { order(name: :desc) }

  concerning :Positions do
    included do
      has_many :positions, dependent: :destroy
      has_many :members, -> { uniq }, through: :positions do
        def founders
          where(positions: { founder: true })
        end

        def team_members
          where(positions: { founder: false })
        end
      end
    end

    def founders_and_team_members
      positions.
        joins(:member).
        where(members: { invitation_token: nil }).
        where.not(members: { confirmed_at: nil }).
        includes(:member).
        group_by(&:founder).
        each_with_object(
          founders: [],
          team_members: []
        ) do |(is_founder, positions), group|
          key = is_founder ? :founders : :team_members
          group[key] = positions.group_by(&:member)
        end
    end
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end
end
