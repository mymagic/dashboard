class Activity
  class Rsvping < Activity
    belongs_to(
      :event,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)

    before_save :cache_data

    %w(event_id event_title state).each do |cached|
      define_method cached do
        data[cached]
      end
    end

    private

    def cache_data
      self.data ||= {}
      self.data['event_title'] = event.title
      self.data['event_id'] = event.id
    end
  end
end
