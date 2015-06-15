class Activity
  class SlotBooking < Activity
    belongs_to(
      :mentor,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)
  end
end
