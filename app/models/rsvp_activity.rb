class RsvpActivity < Activity
  belongs_to(
    :event,
    polymorphic: true,
    foreign_key: :resource_id,
    foreign_type: :resource_type)

  def state
    data["state"]
  end
end
