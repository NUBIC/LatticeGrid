Date::DATE_FORMATS.merge!(
  :justdate => "%m/%d/%Y",
  :db_date => "%Y-%m-%d",
  :integer_date => "%Y%m%d",
  :payment => lambda { |date| date.strftime("%B %e, %Y") }
)
Time::DATE_FORMATS.merge!(
  :justdate => "%m/%d/%Y",
  :db_date => "%Y-%m-%d",
  :integer_date => "%Y%m%d",
  :payment => lambda { |date| date.strftime("%B %e, %Y") }
)