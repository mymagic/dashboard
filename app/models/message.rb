class Message < ActiveRecord::Base
  # Behaviors
  include Searchable

  # Associations
  belongs_to :sender, class_name: 'Member'
  belongs_to :receiver, class_name: 'Member'

  # Validations
  validates :sender, :receiver, :body, presence: true

  # Scopes
  scope :with, -> (participant) { where("sender_id = :id OR receiver_id = :id", id: participant.id) }
  scope :unread, -> { where(unread: true) }

  def self.search(query)
    __elasticsearch__.search({
      query: {
        match: {
          body: query
        }
      },
      highlight: {
        pre_tags: ["<em class='search-highlight'>"],
        post_tags: ["</em>"],
        fields: {
          body: {}
        }
      }
    })
  end

  def as_indexed_json(options = {})
    participant_attrs = {
      methods: :full_name,
      only: :full_name,
      include: :avatar
    }

    as_json(
      include: {
        sender: participant_attrs,
        receiver: participant_attrs
      }
    )
  end
end