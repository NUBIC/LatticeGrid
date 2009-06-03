class Program < ActiveRecord::Base
  has_many :investigator_programs,
    :conditions => ['investigator_programs.end_date is null or investigator_programs.end_date >= :now', {:now => Date.today }]
  has_many :investigators,  
    :through => :investigator_programs
  has_many :program_abstracts,
        :conditions => ['program_abstracts.end_date is null or program_abstracts.end_date >= :now', {:now => Date.today }]
  has_many :abstracts,
        :through => :program_abstracts

  # cache this query
  @@all_programs = nil
  def self.all_programs
    @@all_programs ||= Program.find( :all, :order => "program_number" )
  end
  
  def self.display_abstracts_by_date( program_id, pub_start_date, pub_end_date )
    find(:first,
      :order => "abstracts.year DESC, authors ASC",
      :include => [:abstracts],
  		:conditions => ['programs.id = :program_id AND abstracts.publication_date between :pub_start_date and :pub_end_date', 
   		      {:program_id => program_id, :pub_start_date => pub_start_date, :pub_end_date => pub_end_date}])
  end

#    def investigator_abstracts
#      proxy_target.collect(&:investigator_abstract).uniq
#      def abstract
#        proxy_target.collect(&:abstract)
#      end
#    end
#  has_many :investigator_abstracts, :through => :investigators
#  has_many :abstracts, :through => :investigator_abstracts

 end

