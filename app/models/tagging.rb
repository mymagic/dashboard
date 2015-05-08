class Tagging < ActiveRecord::Base
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true

  validates :taggable, :tag, presence: true
  validates :tag_id, uniqueness: { scope: [:taggable_id, :taggable_type] }
end
