class Message < ActiveRecord::Base
  # Behaviors
  include Searchable
  attr_accessor :network

  # Associations
  belongs_to :sender, class_name: 'Member'
  belongs_to :receiver, class_name: 'Member'

  # Validations
  validates :sender, :receiver, :body, presence: true

  # Scopes
  scope :with, -> (participant) do
    where("sender_id = :id OR receiver_id = :id", id: participant.id)
  end
  scope :unread, -> { where(unread: true) }
  scope :ordered, -> { order(created_at: :asc) }

  after_create :send_notifications

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

  def self.chat_participants_with_member(member)
    # It is equal to ..
    # self.class.find(
    #   messages.pluck(:sender_id, :receiver_id).flatten.uniq - [id])
    Member.
      joins("JOIN messages ON (messages.sender_id = members.id OR "\
            "messages.receiver_id = members.id)").
      where("messages.sender_id = :member OR "\
            "messages.receiver_id = :member", member: member).
      order("messages.created_at DESC").
      where.not(id: member.id)
  end

  private

  def send_notifications
    Notifier.deliver(
      :message_notification,
      receiver,
      message: self,
      network: network)
  end
end
