class Company < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :logo, presence: true, on: :update
  validates :description, length: { minimum: 5 }, allow_blank: true
  validates(
    :website,
    format: { with: URI::regexp(%w(http https)) },
    allow_blank: true)

  # Associations
  belongs_to :community

  scope :ordered, -> { order(name: :desc) }

  concerning :Positions do
    included do
      has_many :companies_members_positions, dependent: :destroy
    end

    def positions_with_members
      Position.positions_with_members(company: self)
    end
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end
end
