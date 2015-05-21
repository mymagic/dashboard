class DateTimeWithStepsInput < SimpleForm::Inputs::DateTimeInput
  def input(wrapper_options = nil)
    input_options[:minute_step] = 15
    input_options[:start_year]  = Date.current.year
    input_options[:end_year]    = Date.current.year + 5
    super
  end

  def input_type
    'datetime'
  end
end
