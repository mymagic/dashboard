module DiscussionsHelper
  def discussion_filter_description
    desc = []
    desc << {
      recent: "Most recent discussions",
      popular: "Discussions sorted by amount of followers",
      hot: "Discussions sorted by amount of followers in the last two weeks",
      unanswered: "Unanswered discussions"
    }[@filter]
    desc << [", tagged with ", content_tag('strong', @tag.name)] if @tag
    safe_join(desc) + '.'
  end
end
