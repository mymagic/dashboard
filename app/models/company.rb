class Company < ActiveRecord::Base
  validates :name, presence: true
  validates :description, length: { minimum: 5 }, allow_blank: true
  validates(
    :website,
    format: { with: URI::regexp(%w(http https)) },
    allow_blank: true)

  has_many :members_positions, class: CompaniesMembersPosition
  has_many :members, through: :members_positions
  has_many :positions, -> { uniq }, through: :members_positions

  scope :ordered, -> { order(name: :desc) }

  def position_and_members
    members_positions.
      each_with_object({}) do |member_position, position_and_members|
      position_and_members[member_position.position] ||= []
      position_and_members[member_position.position] << member_position.member
    end
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end
end
