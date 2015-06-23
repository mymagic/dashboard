class DiscussionTag < Tag
  has_many :discussions,
           through: :taggings,
           source: :taggable,
           source_type: 'Discussion',
           inverse_of: :tags
end
