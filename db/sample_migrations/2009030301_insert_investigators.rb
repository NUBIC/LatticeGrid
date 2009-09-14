class InsertInvestigators < ActiveRecord::Migration
  def self.up

	puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length

	Investigator.create :username => "ava459", :last_name => "Apkarian", :first_name => "Apkar", :middle_name => "V", :pubmed_search_name => "Apkarian A V", :email => "a-apkarian@northwestern.edu"
	Investigator.create :username => "benson", :last_name => "Benson", :first_name => "Al", :middle_name => "B", :pubmed_search_name => "Benson Al", :email => "a-benson@northwestern.edu"
	Investigator.create :username => "mah834", :last_name => "Hummel", :first_name => "Mary", :middle_name => "", :pubmed_search_name => "Hummel M", :pubmed_limit_to_institution => true, :email => "m-hummel@northwestern.edu"
	Investigator.create :username => "philip", :last_name => "Iannaccone", :first_name => "Philip", :middle_name => "M", :pubmed_search_name => "Iannaccone P", :email => "pmi@northwestern.edu"
	Investigator.create :username => "jjones", :last_name => "Jones", :first_name => "Jonathan", :middle_name => "C", :pubmed_search_name => "Jones J C", :pubmed_limit_to_institution => true, :email => "j-jones3@northwestern.edu"

	#600794	1026925	jpc976	jchandler@nmff.org	Chandler	James	P	Neurological Surgery	Regular	FT	Assoc Prof	Clinician	Chicago Campus
	Investigator.create :employee_id => "1026925", :username => "jpc976", :last_name => "Chandler", :first_name => "James", :email => "jchandler@nmff.org"

	puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length

  end

  def self.down
    Investigator.delete_all 
  end
end
