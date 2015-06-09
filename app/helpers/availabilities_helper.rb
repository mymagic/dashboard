module AvailabilitiesHelper
  def one_availability_per_member(availabilities)
    availabilities
  end

  def view_slots_text(availability)
    availability.member == current_member ? 'View' : 'Reserve'
  end

  def slot_available_message(slot)
    return 'Available' if slot.available

    if can? :destroy, slot
      member_link(slot.member)
    else
      'Unavailable'
    end
  end
end
