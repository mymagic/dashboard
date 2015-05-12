module DiscussionsHelper
  def discussion_filter_description(filter, tag:)
    desc = []
    desc << case filter
            when :recent
              "Most recent discussions"
            when :popular
              "Discussions sorted by amount of followers"
            when :hot
              "Discussions sorted by amount of followers in the last two weeks"
            end
    desc << [", tagged with ", content_tag('strong', tag.name)] if tag
    safe_join(desc) + '.'
  end
end
