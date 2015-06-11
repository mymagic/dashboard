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

  def viewing_availabilities?
    controller_name.in? %w(availabilities calendars)
  end

  def member_availability_link(member, date)
    path = community_member_availability_slots_path(
             current_community,
             member,
             year: date.year,
             month: date.month,
             day: date.day)
    safe_join([
      link_to(image_tag(member.avatar.url(:icon), class: 'img-rounded'), path),
      link_to(member.full_name,path)
    ], ' ')
  end
end
