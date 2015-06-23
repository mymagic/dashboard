class Activity
  class Discussing < Activity
    belongs_to(
      :discussion,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)

    before_save :cache_data

    def discussion_title
      data['discussion_title']
    end

    private

    def cache_data
      self.data ||= {}
      self.data['discussion_title'] = discussion.title
    end
  end
end
