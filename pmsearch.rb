#!/usr/bin/env ruby

require 'bio'
require 'lib/pubmedext'

keywords = ARGV.join(' ')
keywords = 'Kibbe Warren[auth]'
keywords = 'Kibbe W A[auth]'
keywords = 'Kibbe W[auth]'
keywords = 'Kibbe Warren Alden[auth]'
keywords = 'Kibbe+W[auth] AND Northwestern[affil]'
#keywords = 'Jameson JL[auth]'
#keywords = 'Jameson JL[auth] AND Northwestern[affil]'
#keywords = 'Chisholm Rex[auth]'
#keywords = 'Chisholm Rex[auth] AND Northwestern[affil]'
#keywords = 'Lee C[auth]'
#keywords = 'Lee Chung[auth]'
#keywords = 'Lee Chung[auth] AND Northwestern[affil]'
#keywords = 'Northwestern[affil]'

options = {
#   'mindate' => '2003/05/31',
#   'maxdate' => '2003/05/31',
  'reldate' => 365,
  'retmax' => 25000,
}
entries = 0

start = Time.now
2.times do
entries = Bio::PubMed.esearch(keywords, options)
end

stop = Time.now

elapsed_seconds = stop.to_f - start.to_f

puts "seconds elapsed = #{elapsed_seconds} for 50 faculty calls"

puts " number of entries found: #{entries.length}"

options = {
  'rettype' => 'abstract',
}

if entries.length > 0 && entries.length > 0 then
Bio::PubMed.efetch(entries, options).each do |entry|
  medline = Bio::MEDLINE.new(entry)
#  puts entry.inspect
   reference = medline.reference
   puts "Journal: #{medline.ta}" #journal Title Abbreviation
   puts "Journal (full?): #{reference.journal}" #journal Title 
   puts "Title: #{reference.title}"
   puts "Publication Date: #{medline.date}"
   puts "Publication Date (DP): #{medline.publication_date.to_s}"
   puts "Electronic Publication Date: #{medline.electronic_publication_date}"  
   puts "MeSH date: #{medline.mhda}"
   puts "Deposit date: #{medline.deposited_date }"
   puts medline.publication_type[0]
   puts  reference.url
   puts "Status: #{medline.status}"
   puts "Publication status: #{medline.publication_status}"
   
#   puts medline.inspect
    puts medline.fau #full author list
   puts ""
   puts " "
#   puts reference.authors
#  puts reference.title
#  puts reference.journal
#  puts reference.volume
#   puts reference.issue
#   puts reference.pages
#   puts reference.year
#   puts "Pubmed: #{reference.pubmed}"
#   puts "Medline: ",reference.medline
#   puts "URL: ",reference.url
#puts "MESH: ",reference.mesh
#puts "MESH string: ",reference.mesh.join(";\n")
#  puts "reference object: #{reference.inspect}"
#   puts "Abstract: ",reference.abstract
#   puts reference.endnote
   
end

end
