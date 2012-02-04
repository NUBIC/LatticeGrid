require 'rubygems'
require 'bio'
require 'dicty_pubmed_ids'

namespace :dicty do
  desc "pull in the pubmed records and output formatted for the PubMed (NLM) EndNote filter"
  task :generate_dictybase_biblio => :environment do
    ids = @dicty_pubmed_ids
    puts "Found #{@dicty_pubmed_ids.length} pubmed ids"
    ids.each_with_index do |id, j|
      begin
        entry = Bio::PubMed.query(id)
        puts entry
        medline = Bio::MEDLINE.new(entry)
        reference = medline.reference
        reference.endnote =~ /.*%U([^\r\n]*).*/
        puts "URL -"+$1
        puts
      rescue
        puts
        puts "Error: unable to find pubmed id #{id}"
        puts
      end
      #break if j > 10
    end
  end
    
  task :generate_file => :environment do
    abstracts = Abstract.all(:limit=>50)
    abstracts.each do |abs|
      puts abs.endnote_citation
      puts
      puts
    end
  end

end

