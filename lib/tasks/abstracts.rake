require 'publication_utilities' #specific methods
require 'utilities' #specific methods

task :checkForAbstractsWithNoInvestigators => :environment do
  block_timing("checkForAbstractsWithNoInvestigators") {
    @AbstractsNoInvestigators = Abstract.without_investigators()
    puts "abstracts without investigators: #{@AbstractsNoInvestigators.length}"
  }
end

task :deleteAbstractsWithNoInvestigators => :environment do
  block_timing("deleteAbstractsWithNoInvestigators") {
    @AbstractsNoInvestigators = Abstract.without_investigators()
    puts "deleting #{@AbstractsNoInvestigators.length} abstracts without investigators."
    @AbstractsNoInvestigators.each do |abstract|
      abstract.delete
    end
    puts "done."
  }
end

task :checkForInvestigatorsWithNoPrograms => :environment do
  block_timing("checkForInvestigatorsWithNoPrograms") {
    @InvestigatorsNoPrograms = Investigator.without_programs()
    @InvestigatorsNoPrograms.each do |inv|
      puts "#{inv.name} is has no memberships"
    end
    
    puts "investigators without programs: #{@InvestigatorsNoPrograms.length}"
  }
end

task :deleteInvestigatorsWithNoPrograms => :environment do
  block_timing("deleteInvestigatorsWithNoPrograms") {
    @InvestigatorsNoPrograms = Investigator.without_programs()
    puts "deleting #{@InvestigatorsNoPrograms.length} investigators with no programs."
    purgeInvestigators(@InvestigatorsNoPrograms)
    puts "done."
  }
end

task :checkValidAbstractsWithoutInvestigators => :environment do
  block_timing("checkValidAbstracts") {
    @AbstractsNoInvestigators = Abstract.without_valid_investigators()
    puts "abstracts without investigators: #{@AbstractsNoInvestigators.length}"
  }
end

task :removeValidAbstractsWithoutInvestigators => :environment do
  block_timing("removeValidAbstractsWithoutInvestigators") {
    @AbstractsNoInvestigators = Abstract.without_valid_investigators()
    puts "abstracts without investigators: #{@AbstractsNoInvestigators.length}"
    #maybe rewrite with an update_all
    @AbstractsNoInvestigators.each do |abstract|
      abstract.is_valid         = false
      abstract.reviewed_at    ||= Time.now
      abstract.last_reviewed_at = Time.now
      abstract.reviewed_id    ||= 0
      abstract.last_reviewed_id = 0
      abstract.reviewed_ip    ||= 'removeValidAbstracts'
      abstract.last_reviewed_ip = 'removeValidAbstracts'
      abstract.save!
    end
  }
  puts "#{@AbstractsNoInvestigators.length} abstracts have been marked as deleted"
end

task :reinstateAbstractsWithInvestigators => :environment do
  marked=0
  block_timing("reinstateAbstractsWithInvestigators") {
     @AbstractsWithInvestigators = Abstract.invalid_with_investigators_unreviewed()
    puts "deleted abstracts with investigators: #{@AbstractsWithInvestigators.length}"
    @AbstractsWithInvestigators.each do |abstract|
      if (abstract.last_reviewed_id.blank? or abstract.last_reviewed_id < 1) then
        abstract.is_valid         = true
        abstract.reviewed_at    ||= Time.now
        abstract.last_reviewed_at = Time.now
        abstract.reviewed_id    ||= nil
        abstract.last_reviewed_id = nil
        abstract.reviewed_ip    ||= 'reinstateValidAbstracts'
        abstract.last_reviewed_ip = 'reinstateValidAbstracts'
        abstract.save!
        marked+=1
      end
    end
  }
  puts "#{marked} abstracts have been reinstated"
end

task :checkDeletedAbstractsWithActiveInvestigators => :environment do
  block_timing("checkDeletedAbstractsWithActiveInvestigators") {
    @DeletedAbstractsWithInvestigators = Abstract.invalid_with_investigators_unreviewed()
    puts "Deleted abstracts with investigators: #{@DeletedAbstractsWithInvestigators.length}"
  }
end

task :checkAbstractsWithMissingDates => :environment do
  block_timing("checkAbstractsWithMissingDates") {
    @checkAbstractsWithMissingDates = Abstract.abstracts_with_missing_dates()
    puts "Abstracts with missing dates: #{@checkAbstractsWithMissingDates.length}"
    @checkAbstractsWithMissingDates = Abstract.abstracts_with_missing_publication_date()
    puts "Abstracts with missing publication date: #{@checkAbstractsWithMissingDates.length}"
    @checkAbstractsWithMissingDates = Abstract.abstracts_with_missing_electronic_publication_date()
    puts "Abstracts with missing electronic publication date: #{@checkAbstractsWithMissingDates.length}"
    @checkAbstractsWithMissingDates = Abstract.abstracts_with_missing_deposited_date()
    puts "Abstracts with missing deposited date: #{@checkAbstractsWithMissingDates.length}"
    
  }
end

task :updateAbstractsMissingCreationDate => :environment do
  block_timing("checkAbstractsWithMissingDates") {
    @abstractsWithMissingDates = Abstract.all(:conditions=>"pubmed_creation_date is null")
    @abstractsWithMissingDates.each do |abstract|
      unless abstract.pubmed.blank?
        pubs = Bio::PubMed.efetch(abstract.pubmed)
        unless pubs.blank? or pubs[0].blank?
          medline = Bio::MEDLINE.new(pubs[0])
          puts "crdt: #{medline.creation_date}; pmid: #{abstract.pubmed}; year: #{abstract.year}; edat - #{abstract.electronic_publication_date}"
          abstract.pubmed_creation_date = medline.creation_date
          abstract.save!
        else
          puts "efetch failed for pubmed_id #{abstract.pubmed}"
        end
      end
    end
  }
end

task :updateAbstractsMissingPublicationDate => :environment do
  block_timing("checkAbstractsWithMissingDates") {
    @abstractsWithMissingDates = Abstract.all(:conditions=>"publication_date is null")
    puts "processing #{@abstractsWithMissingDates.length} abstracts"
    @abstractsWithMissingDates.each do |abstract|
      unless abstract.pubmed.blank?
        pubs = Bio::PubMed.efetch(abstract.pubmed)
        unless pubs.blank? or pubs[0].blank?
          medline = Bio::MEDLINE.new(pubs[0])
          begin
            puts "pubdate: #{abstract.publication_date}; pmid: #{abstract.pubmed}; year: #{abstract.year}; edat - #{abstract.electronic_publication_date}; dp: #{medline.dp}: pubdate from medline: #{medline.publication_date}" if medline.publication_date.to_date.year != abstract.year.to_i 
            if medline.publication_date.to_date.to_s != abstract.publication_date.to_s
              puts "new pubdate: #{abstract.publication_date}; pmid: #{abstract.pubmed}; year: #{abstract.year}; edat - #{abstract.electronic_publication_date}; dp: #{medline.dp}: pubdate from medline: #{medline.publication_date}"
              abstract.publication_date = medline.publication_date 
              abstract.save!
            end
          rescue
            puts "pubdate ERROR from medline: #{abstract.publication_date}; pmid: #{abstract.pubmed}; year: #{abstract.year}; edat - #{abstract.electronic_publication_date}; dp: #{medline.dp}: pubdate from medline: #{medline.publication_date}"
          end
        else
          puts "efetch failed for pubmed_id #{abstract.pubmed}"
        end
      end
    end
  }
end
  
task :correctAbstractsWithMissingPublicationDatesAndGoodEpubDates => :environment do
  block_timing("correctAbstractsWithMissingPublicationDatesAndGoodEpubDates") {
    @abstractsWithMissingDates = Abstract.abstracts_with_missing_publication_date_and_good_edate()
    @abstractsWithMissingDates.each do |abstract|
      abstract.publication_date = abstract.electronic_publication_date
      abstract.save!
    end
    puts "Abstracts corrected with missing dates: #{@abstractsWithMissingDates.length}"
  }
end
  
task :countAbstractsMismatchingEPubDateAndCreationDate => :environment do
  block_timing("countAbstractsMismatchingEPubDateAndCreationDate") {
    @abstractsWithMismatchedDates = Abstract.all(:conditions=>"pubmed_creation_date is not null and pubmed_creation_date != electronic_publication_date and publication_date is null ")
    puts "#{@abstractsWithMismatchedDates.length} abstracts have a different pubmed_creation_date and electronic_publication_date"
    @abstractsWithMismatchedDates.each do |abstract|
      puts "crdt: #{abstract.pubmed_creation_date}; pmid: #{abstract.pubmed}; year: #{abstract.year}; edat - #{abstract.electronic_publication_date}"
    end
  }
end


