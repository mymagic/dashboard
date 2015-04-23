module MembersConcern

  protected

  def member_create_params
    member_params.tap do |attrs|
      attrs[:community_id] = current_community.id

      if attrs[:companies_positions_attributes]
        attrs[:companies_positions_attributes].map do |k, v|
          if k.is_a? Hash
            k[:approver_id] = current_member.id
          else
            v[:approver_id] = current_member.id
          end
        end
      end
    end
  end
end
