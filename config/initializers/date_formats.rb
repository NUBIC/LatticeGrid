ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :justdate => "%m/%d/%Y",
  :db_date => "%Y-%m-%d",
  :integer_date => "%Y%m%d"
)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :justdate => "%m/%d/%Y",
  :db_date => "%Y-%m-%d",
  :integer_date => "%Y%m%d"
)