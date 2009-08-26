date_formats = { :payment => lambda { |date| date.strftime("%B %e, %Y") } }

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.update(date_formats)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(date_formats)
# DateTime uses Time's DATE_FORMATS, so there's nothing to update for it.