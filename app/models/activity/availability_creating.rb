class Activity
  class AvailabilityCreating < Activity
    belongs_to(
      :availability,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)

    before_save :cache_data

    alias_method :mentor, :owner

    def date
      @date ||= Date.parse(data['date'])
    end

    private

    def cache_data
      self.data ||= {}
      self.data['date'] = availability.date
    end
  end
end
