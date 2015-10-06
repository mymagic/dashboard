class CalendarFeedsController < ApplicationController
  include TokenAuthenticationConcern
  include ActionController::MimeResponds

  skip_before_action :authorize_through_magic_connect!,
    :authorize_community!

  def subscribe
    @events = send("get_#{params[:type]}")
    calendar = Icalendar::Calendar.new
    @events.each do |event|
      calendar.add_event(event.to_ics)
    end

    respond_to do |format|
      format.ics { render text: calendar.to_ical, layout: false }
    end
  end

  def reservations
    slots = current_member.slots.includes(:availability)
    rsvps = current_member.rsvps.includes(:event)

    calendar = Icalendar::Calendar.new
    slots.each do |slot|
      calendar.add_event(
        slot.availability.to_ics(
          reserved: true, start_time: slot.start_time, end_time: slot.end_time
        )
      )
    end

    rsvps.each do |rsvp|
      calendar.add_event(rsvp.event.to_ics(reserved: true, state: rsvp.state))
    end

    respond_to do |format|
      format.ics { render text: calendar.to_ical, layout: false }
    end
  end

  def get_events
    current_network.events.includes(:creator)
  end

  def get_availabilities
    current_network.availabilities.includes(:member)
  end
end
