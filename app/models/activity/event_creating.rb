class Activity
  class EventCreating < Activity
    belongs_to(
      :event,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)
  end
end
