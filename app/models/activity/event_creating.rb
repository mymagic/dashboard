class Activity
  class EventCreating < Activity
    belongs_to(
      :event,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)
    before_save :cache_data

    %w(event_id event_title).each do |cached|
      define_method cached do
        data[cached]
      end
    end

    def event_starts_at
      DateTime.parse(data['event_starts_at'])
    end

    private

    def cache_data
      self.data ||= {}
      self.data['event_title'] = event.title
      self.data['event_id'] = event.id
      self.data['event_starts_at'] = event.starts_at
    end
  end
end
