class Company < ActiveRecord::Base
  validates :name, presence: true
  validates :logo, presence: true, on: :update
  validates :description, length: { minimum: 5 }, allow_blank: true
  validates(
    :website,
    format: { with: URI::regexp(%w(http https)) },
    allow_blank: true)

  has_many(:members_positions,
           class: CompaniesMembersPosition,
           dependent: :destroy,
           inverse_of: :company)
  has_many :members, through: :members_positions
  has_many :positions, -> { uniq }, through: :members_positions

  has_many(:approved_members_positions,
           -> { approved },
           class: CompaniesMembersPosition,
           dependent: :destroy)
  has_many :approved_positions, -> { uniq }, source: :position, through: :approved_members_positions
  has_many :approved_members, source: :member, through: :approved_members_positions

  mount_uploader :logo, LogoUploader

  scope :ordered, -> { order(name: :desc) }

  def approved_positions_and_members
    approved_members_positions.
      sort_by(&:position_priority_order).
      each_with_object({}) do |member_position, position_and_members|
      position_and_members[member_position.position] ||= []
      position_and_members[member_position.position] << member_position.member
    end
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end
end
