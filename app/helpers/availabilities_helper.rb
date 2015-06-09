module AvailabilitiesHelper
  def view_slots_text(availability)
    availability.member == current_member ? 'View' : 'Reserve'
  end
end
