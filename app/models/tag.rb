class Tag < ActiveRecord::Base
  belongs_to :community
  has_many :taggings, dependent: :destroy

  validates :name, :type, :community, presence: true
  validates :name, uniqueness: { scope: [:type, :community_id] }

  def to_param
    "#{ id }-#{ name.parameterize }"
  end

  def destroy_if_orphaned!
    destroy if reload.taggings.empty?
  end
end
