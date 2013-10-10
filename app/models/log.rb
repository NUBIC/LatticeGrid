# == Schema Information
# Schema version: 20130327155943
#
# Table name: logs
#
#  action_name     :string(255)
#  activity        :string(255)
#  controller_name :string(255)
#  created_at      :timestamp
#  created_ip      :string(255)
#  id              :integer          default(0), not null, primary key
#  investigator_id :integer
#  params          :text
#  program_id      :integer
#  updated_at      :timestamp
#

class Log < ActiveRecord::Base
  belongs_to :organizational_unit, :foreign_key => 'program_id'
  belongs_to :investigator
  
  named_scope :logins, :conditions => ["logs.activity = 'login'"], :include => [:investigator]
  named_scope :approved_profiles, :conditions => ["logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve profile%%'"]  #need to escape the % with itself!
  named_scope :approved_publications, :conditions => ["logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve publication%%'"]
  named_scope :logins_by_investigator_id, :select=>"logs.investigator_id",  
    :conditions => ["activity = 'login'"],
    :group => 'investigator_id'
 
  named_scope :any_approval_by_investigator_id, :select=>"logs.investigator_id",  
    :conditions => ["activity LIKE '%%update%%' and params LIKE '%%Approve%%'"],
    :group => 'investigator_id'
  named_scope :last_approved_profiles_by_id, :select=>"max(logs.id) as id, logs.investigator_id",  
    :conditions => ["activity LIKE '%%update%%' and params LIKE '%%Approve profile%%'"],
    :group => 'investigator_id'
  named_scope :last_approved_publications_by_id, :select=>"max(logs.id) as id, logs.investigator_id",  
    :conditions => ["activity LIKE '%%update%%' and params LIKE '%%Approve publication%%'"],
    :group => 'investigator_id'
  named_scope :for_ids, lambda { |*ids|
      {:joins => [:investigator], 
       :conditions => ['logs.id IN (:ids) ', {:ids => ids.first}] }
  }
  named_scope :logins_for_investigator_ids, lambda { |*ids|
      {:joins => [:investigator], 
       :conditions => ["activity = 'login' and logs.investigator_id IN (:ids) ", {:ids => ids.first}] }
  }

  named_scope :logins_after, lambda { |*ids|
    {
      :include => [:investigator],
      :conditions => ["logs.activity = 'login' and logs.created_at > :after_date", 
        {:after_date=>(ids.first||'01-JAN-2000')}]
    }
  }
  named_scope :approved_profiles_after,  lambda { |*ids|
    {
      :conditions => ["logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve profile%%' and logs.created_at > :after_date", 
        {:after_date=>(ids.first||'01-JAN-2000')}]
    }
  }
  named_scope :approved_publications_after, lambda { |*ids|
    {
      :conditions => ["logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve publication%%' and logs.created_at > :after_date", 
        {:after_date=>(ids.first||'01-JAN-2000')}]
    }
  }

  named_scope :logins_by_investigator_id_after, lambda { |*ids|
    {
      :select=>"logs.investigator_id",  
      :conditions => ["logs.activity = 'login' and logs.created_at > :after_date", 
        {:after_date=>(ids.first||'01-JAN-2000')}],
      :group => 'investigator_id'
    }
  }
  
  named_scope :last_approved_profiles_by_id_after, lambda { |*ids|
    {
      :select=>"max(logs.id) as id, logs.investigator_id",  
      :conditions => ["logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve profile%%' and logs.created_at > :after_date", 
        {:after_date=>(ids.first||'01-JAN-2000')}],
      :group => 'investigator_id'
    }
  }

  named_scope :last_approved_publications_by_id_after, lambda { |*ids|
    {
      :select=>"max(logs.id) as id, logs.investigator_id",  
      :conditions => ["logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve publication%%' and logs.created_at > :after_date", 
        {:after_date=>(ids.first||'01-JAN-2000')}],
      :group => 'investigator_id'
    }
  }

end
