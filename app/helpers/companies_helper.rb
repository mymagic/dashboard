module CompaniesHelper
  def company_filter_description
    {
      portfolio: "All companies on #{ current_community.name }.",
      mine: "All companies you work for."
    }[@filter]
  end

  def website_link(company)
    link_to(
      company.website.gsub(/https?:\/\//, ''),
      company.website, target: '_blank')
  end

  def company_link(company)
    safe_join([company_logo_link(company), company_name_link(company)], ' ')
  end

  def company_logo_link(company)
    link_to(
      image_tag(company.logo.url(:icon), class: 'img-rounded'),
      [current_community, current_network, company]
    )
  end

  def company_name_link(company)
    link_to(company.name, [current_community, current_network, company])
  end
end
