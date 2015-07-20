class Tag < ActiveRecord::Base
  # Associations
  belongs_to :network
  has_many :taggings, dependent: :destroy

  # Validations
  validates :name, :type, :network, presence: true
  validates :name, uniqueness: { scope: [:type, :network_id] }

  def to_param
    "#{ id }-#{ name.parameterize }"
  end

  def destroy_if_orphaned!
    destroy if reload.taggings.empty?
  end
end
