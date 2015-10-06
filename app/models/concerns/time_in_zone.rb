module TimeInZone
  extend ActiveSupport::Concern

  included do
    def datetime(date, time)
      offset = ActiveSupport::TimeZone.new(time_zone).formatted_offset(true)
      DateTime.new(date.year, date.month, date.day,
        time.hour, time.min, time.sec, offset)
    end
  end

  module ClassMethods
    def time_in_zone_for(*attrs)
      attrs.each do |name|
        define_method(name) do |*params|
          value_from_super = super(*params)

          if has_attribute?(:time_zone) && time_zone.present? && value_from_super
            value_from_super.in_time_zone(time_zone)
          else
            value_from_super
          end
        end
      end
    end
  end
end
