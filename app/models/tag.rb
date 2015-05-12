class Tag < ActiveRecord::Base
  # Behaviors
  include Searchable

  # Associations
  belongs_to :community
  has_many :taggings, dependent: :destroy

  # Validations
  validates :name, :type, :community, presence: true
  validates :name, uniqueness: { scope: [:type, :community_id] }

  def self.search(query)
    __elasticsearch__.search({
      query: {
        wildcard: {
          name: "#{query}*"
        }
      }
    })
  end

  def to_param
    "#{ id }-#{ name.parameterize }"
  end

  def destroy_if_orphaned!
    destroy if reload.taggings.empty?
  end
end
