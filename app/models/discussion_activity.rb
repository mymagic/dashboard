class DiscussionActivity < Activity
  belongs_to(
    :discussion,
    polymorphic: true,
    foreign_key: :resource_id,
    foreign_type: :resource_type)
end
