class Log < ActiveRecord::Base
  belongs_to :program
  belongs_to :investigator
  
  named_scope :logins, :conditions => ["activity = 'login'"]
  named_scope :submissions, :conditions => ["activity LIKE '%%submission%%'"]  #need to escape the % with itself!
  named_scope :reviews, :conditions => ["activity LIKE '%%review%%'"]
  
end
