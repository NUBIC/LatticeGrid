class InvestigatorAbstract < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :abstract
  
  has_many :investigator_appointments, 
    :through => :investigator, 
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  named_scope :first_author_abstracts, :conditions => ['investigator_abstracts.is_first_author = true and investigator_abstracts.is_valid = true']

  named_scope :last_author_abstracts, :conditions => ['investigator_abstracts.is_last_author = true and investigator_abstracts.is_valid = true']

  named_scope :first_or_last_author_abstracts, :conditions => ['(investigator_abstracts.is_first_author = true or investigator_abstracts.is_last_author = true) and investigator_abstracts.is_valid = true']

  validates_uniqueness_of :investigator_id, :scope => "abstract_id"
  
  named_scope :remove_invalid,  :conditions => 'investigator_abstracts.is_valid = true'
  named_scope :only_valid,  :conditions => 'investigator_abstracts.is_valid = true'
  named_scope :only_invalid,  :conditions => 'investigator_abstracts.is_valid = false'
  named_scope :remove_deleted,  :conditions => 'investigator_abstracts.end_date is null'
  named_scope :only_deleted,  :conditions => 'investigator_abstracts.end_date is not null'
  named_scope :by_date_range, lambda { |*args| {:conditions => ['investigator_abstracts.publication_date between :start_date and :end_date', 
                {:start_date => args.first, :end_date => args.last} ] }}
  named_scope :for_investigator_ids, lambda { |*ids| {:conditions => ['investigator_abstracts.investigator_id IN (:pi_ids)', 
                {:pi_ids => ids.first} ] }}


  def self.investigator_shared_publication_count_by_date_range(investigator_id,start_date,end_date)
    abs = all(:select=>"abstract_id", 
      :conditions => ['investigator_abstracts.investigator_id = :investigator_id and investigator_abstracts.is_valid = true and investigator_abstracts.publication_date between :start_date and :end_date', 
          {:investigator_id => investigator_id, :start_date => start_date, :end_date => end_date} ] )
    abstract_ids = abs.map(&:abstract_id)
    the_hash = InvestigatorAbstract.count(
      :group => "investigator_id",
      :conditions => ['investigator_abstracts.abstract_id IN (:ids) AND investigator_abstracts.is_valid = true AND NOT investigator_abstracts.investigator_id = :investigator_id', {:ids => abstract_ids, :investigator_id => investigator_id }]
    )
    return nil if the_hash.keys.blank?
    pis = Investigator.all(:conditions=> ['investigators.id IN (:ids)', {:ids => the_hash.keys}]) 
    pis.each do |pi|
      pi["shared_publication_count"] = the_hash[pi.id]
    end
    pis
  end
end
