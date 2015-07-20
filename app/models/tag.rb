class Tag < ActiveRecord::Base
  # Associations
  belongs_to :network
  has_many :taggings, dependent: :destroy

  # Validations
  validates :name, :type, :community, presence: true
  validates :name, uniqueness: { scope: [:type, :community_id] }

  def to_param
    "#{ id }-#{ name.parameterize }"
  end

  def destroy_if_orphaned!
    destroy if reload.taggings.empty?
  end
end
