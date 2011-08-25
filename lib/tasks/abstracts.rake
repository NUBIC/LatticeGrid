require 'publication_utilities' #specific methods
require 'utilities' #specific methods

task :checkForAbstractsWithNoInvestgators => :environment do
  block_timing("checkForAbstractsWithNoInvestgators") {
    @AbstractsNoInvestigators = Abstract.without_investigators()
    puts "abstracts without investigators: #{@AbstractsNoInvestigators.length}"
  }
end

task :deleteAbstractsWithNoInvestgators => :environment do
  block_timing("deleteAbstractsWithNoInvestgators") {
    @AbstractsNoInvestigators = Abstract.without_investigators()
    puts "deleting #{@AbstractsNoInvestigators.length} abstracts without investigators."
    @AbstractsNoInvestigators.each do |abstract|
      abstract.delete
    end
    puts "done."
  }
end

task :checkForInvestgatorsWithNoPrograms => :environment do
  block_timing("checkForAbstractsWithNoInvestgators") {
    @AbstractsNoInvestigators = Investigators.without_programs()
    puts "abstracts without investigators: #{@AbstractsNoInvestigators.length}"
  }
end

task :deleteInvestgatorsWithNoPrograms => :environment do
  block_timing("deleteAbstractsWithNoInvestgators") {
    @AbstractsNoInvestigators = Abstract.without_investigators()
    puts "deleting #{@AbstractsNoInvestigators.length} abstracts without investigators."
    @AbstractsNoInvestigators.each do |abstract|
      abstract.delete
    end
    puts "done."
  }
end

task :checkValidAbstracts => :environment do
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
     @AbstractsWithInvestigators = Abstract.deleted_with_investigators()
    puts "deleted abstracts with investigators: #{@AbstractsWithInvestigators.length}"
    @AbstractsWithInvestigators.each do |abstract|
      if (abstract.deleted_id.blank? or abstract.deleted_id < 1) and (abstract.deleted_ip.blank? or abstract.deleted_ip =='checkValidAbstracts' ) then
        abstract.is_valid         = true
        abstract.reviewed_at    ||= Time.now
        abstract.last_reviewed_at = Time.now
        abstract.reviewed_id    ||= 0
        abstract.last_reviewed_id = 0
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
    @DeletedAbstractsWithInvestigators = Abstract.deleted_with_investigators()
    puts "Deleted abstracts with investigators: #{@DeletedAbstractsWithInvestigators.length}"
  }
end
