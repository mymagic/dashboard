class Activity
  class Following < Activity
    belongs_to(
      :followable,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)
  end
end
