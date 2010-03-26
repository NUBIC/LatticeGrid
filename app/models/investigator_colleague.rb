class InvestigatorColleague < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :colleague, :class_name => 'Investigator'
  
  def publications()
    Abstract.find(:all, 
      :conditions=>["id IN (:publication_list)", {:publication_list => self.publication_list.split(",")}],
      :order => "publication_date DESC, electronic_publication_date DESC, authors ASC")
  end
  named_scope :mesh_ic, lambda { |*args| {:conditions => ['mesh_tags_ic >= :mesh_ic', {:mesh_ic => args.first} ] }}
  named_scope :shared_pubs, lambda { |*args| {:conditions => ['publication_cnt >= :shared_pubs', {:shared_pubs => args.first} ] }}
  
end
