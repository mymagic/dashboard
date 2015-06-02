module Followable
  extend ActiveSupport::Concern

  included do
    has_many(
      :followings,
      as: :followable,
      dependent: :destroy,
      inverse_of: :followable,
      class_name: 'Follow')
    has_many(
      :followers,
      through: :followings,
      source: :member,
      class_name: 'Member')
  end
end
