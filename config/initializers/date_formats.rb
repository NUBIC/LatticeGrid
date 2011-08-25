ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :justdate => "%m/%d/%y",
  :db_date => "%Y-%m-%d"
)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :justdate => "%m/%d/%y",
  :db_date => "%Y-%m-%d"
)