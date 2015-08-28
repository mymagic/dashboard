FactoryGirl.define do
  factory :discussion_tagging, class: Tagging do
    tag { create(:tag, :discussion_tag) }
    taggable_type 'Discussion'
    taggable { create(:discussion, network: tag.network) }
  end
end
