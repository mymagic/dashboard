class CommentActivity < Activity
  belongs_to(
    :comment,
    polymorphic: true,
    foreign_key: :resource_id,
    foreign_type: :resource_type)

  belongs_to(
    :discussion,
    polymorphic: true,
    foreign_key: :secondary_resource_id,
    foreign_type: :secondary_resource_type)
end
