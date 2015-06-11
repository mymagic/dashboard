module CompaniesHelper
  def company_filter_description
    {
      portfolio: "All companies on #{ current_community.name }.",
      mine: "All companies you work for."
    }[@filter]
  end

  def website_link(company)
    link_to(company.website.gsub(/https?:\/\//,''), company.website, target: '_blank')
  end
end
