module ActivitiesHelper
  def activity_filter_description
    {
      personal: "Activities of members and discussions you follow.",
      public: "All activities in #{ current_community.name }."
    }[@filter]
  end
end
