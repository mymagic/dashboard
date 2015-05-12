class Follow < ActiveRecord::Base
  belongs_to :member

  belongs_to :member
  belongs_to :followable, polymorphic: true, counter_cache: true

  validates :member, :followable, presence: true
  validates :followable_id, uniqueness: { scope: [:member_id, :followable_type] }
end
