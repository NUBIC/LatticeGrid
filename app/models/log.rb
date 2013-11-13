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

  scope :logins, includes(:investigator), where("logs.activity = 'login'")
  scope :approved_profiles, where("logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve profile%%'")  #need to escape the % with itself!
  scope :approved_publications, where("logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve publication%%'")
  scope :logins_by_investigator_id, select("logs.investigator_id"), where("activity = 'login'"), group('investigator_id')

  scope :any_approval_by_investigator_id, select('logs.investigator_id'),
    where("activity LIKE '%%update%%' and params LIKE '%%Approve%%'"),
    group('investigator_id')

  scope :last_approved_profiles_by_id, select("max(logs.id) as id, logs.investigator_id"),
    where("activity LIKE '%%update%%' and params LIKE '%%Approve profile%%'"),
    group('investigator_id')

  scope :last_approved_publications_by_id, select('max(logs.id) as id, logs.investigator_id'),
    where("activity LIKE '%%update%%' and params LIKE '%%Approve publication%%'"),
    group('investigator_id')

  scope :for_ids, lambda { |*ids|
      { joins(:investigator), where('logs.id IN (:ids) ', { :ids => ids.first }) }
  }
  scope :logins_for_investigator_ids, lambda { |*ids|
      { joins(:investigator), where("activity = 'login' and logs.investigator_id IN (:ids) ", { :ids => ids.first }) }
  }

  scope :logins_after, lambda { |*ids|
    { includes(:investigator), where("logs.activity = 'login' and logs.created_at > :after_date", { :after_date => ( ids.first || '01-JAN-2000' ) }) }
  }
  scope :approved_profiles_after,  lambda { |*ids|
    { where("logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve profile%%' and logs.created_at > :after_date", { :after_date => ( ids.first || '01-JAN-2000' ) }) }
  }
  scope :approved_publications_after, lambda { |*ids|
    { where("logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve publication%%' and logs.created_at > :after_date", { :after_date => ( ids.first || '01-JAN-2000' ) }) }
  }

  scope :logins_by_investigator_id_after, lambda { |*ids|
    {
      select('logs.investigator_id'),
      where("logs.activity = 'login' and logs.created_at > :after_date", { :after_date => ( ids.first || '01-JAN-2000' ) }),
      group('investigator_id')
    }
  }

  scope :last_approved_profiles_by_id_after, lambda { |*ids|
    {
      select('max(logs.id) as id, logs.investigator_id'),
      where("logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve profile%%' and logs.created_at > :after_date", { :after_date => ( ids.first || '01-JAN-2000' ) }),
      group('investigator_id')
    }
  }

  scope :last_approved_publications_by_id_after, lambda { |*ids|
    {
      select('max(logs.id) as id, logs.investigator_id'),
      where("logs.activity LIKE '%%update%%' and logs.params LIKE '%%Approve publication%%' and logs.created_at > :after_date", { :after_date => ( ids.first || '01-JAN-2000' ) }),
      group('investigator_id')
    }
  }

end
