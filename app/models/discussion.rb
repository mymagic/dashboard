class Discussion < ActiveRecord::Base
  # Associations
  belongs_to :community
  belongs_to :author, class: Member

  validates :title, :body, :author, :community, presence: true

  before_validation :set_community, if: :author

  protected

  def set_community
    self.community = author.community
  end
end
