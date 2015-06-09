module AvailabilitiesHelper
  def view_slots_text(availability)
    availability.member == current_member ? 'View' : 'Reserve'
  end

  def slot_available_message(slot)
    return 'Available' if slot.available
    
    if can? :manage, @availability
      "Reserved By #{slot.member.try(:full_name)}"
    else
      'Unavailable'
    end
  end
end
