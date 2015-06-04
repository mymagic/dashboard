module CompaniesHelper
  def company_filter_description(filter)
    {
      portfolio: "All companies on #{ current_community.name }.",
      mine: "All companies you work for."
    }[filter]
  end
end
