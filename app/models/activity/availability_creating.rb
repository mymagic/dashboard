class Activity
  class AvailabilityCreating < Activity
    belongs_to(
      :availability,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)
  end
end
