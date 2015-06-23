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

  def discussion_link(discussion)
    link_to(
      discussion.title,
      community_discussion_path(current_community, discussion))
  end

  def discussion_meta(discussion)
    o = [
      "Posted by #{ discussion.author.full_name },",
      time_tag(discussion.created_at) + '.',
      pluralize(discussion.follows_count, 'follower')
    ]

    if discussion.comments_count.to_i > 0
      o << "and #{ pluralize(discussion.comments_count, 'reply') }, "\
           "latest from #{ discussion.comments.first.author.full_name }"
    end

    safe_join(o, ' ') + '.'
  end
end
