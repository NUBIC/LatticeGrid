class InvestigatorColleague < ActiveRecord::Base
  belongs_to :investigator
  #need this for a bug in Rails 2.3.5
  belongs_to :colleague, :class_name => 'Investigator', :foreign_key => 'colleague_id'
  
  def publications()
    Abstract.find(:all, 
      :conditions=>["abstracts.id IN (:publication_list)", {:publication_list => self.publication_list.split(",")}],
      :order => "abstracts.publication_date DESC, electronic_publication_date DESC, authors ASC")
  end
  named_scope :mesh_ic, lambda { |*args| {:conditions => ['mesh_tags_ic >= :mesh_ic', {:mesh_ic => args.first} ] }}
  named_scope :shared_pubs, lambda { |*args| {:conditions => ['publication_cnt >= :shared_pubs', {:shared_pubs => args.first} ] }}
  
end
