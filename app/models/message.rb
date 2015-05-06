class Message < ActiveRecord::Base
  # Behaviors
  include Searchable

  # Associaltions
  belongs_to :sender, class_name: 'Member'
  belongs_to :receiver, class_name: 'Member'

  # Validations
  validates :sender, :receiver, :body, presence: true
end
