module TimeInZone
  extend ActiveSupport::Concern

  module ClassMethods
    def time_in_zone_for(*attrs)
      attrs.each do |name|
        define_method(name) do |*params|
          value_from_super = super(*params)

          if has_attribute?(:time_zone) && value_from_super
            value_from_super.in_time_zone(time_zone)
          else
            value_from_super
          end
        end
      end
    end
  end
end
