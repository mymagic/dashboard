class SignupActivity < Activity
  belongs_to(
    :invited_by,
    polymorphic: true,
    foreign_key: :resource_id,
    foreign_type: :resource_type)
end
