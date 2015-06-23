class Activity
  class Commenting < Activity
    belongs_to(
      :comment,
      polymorphic: true,
      foreign_key: :resource_id,
      foreign_type: :resource_type)

    belongs_to(
      :discussion,
      polymorphic: true,
      foreign_key: :secondary_resource_id,
      foreign_type: :secondary_resource_type)

    before_save :cache_data

    %w(discussion_id discussion_title).each do |cached|
      define_method cached do
        data[cached]
      end
    end

    private

    def cache_data
      self.data ||= {}
      self.data['discussion_title'] = comment.discussion.title
      self.data['discussion_id'] = comment.discussion.id
    end
  end
end
