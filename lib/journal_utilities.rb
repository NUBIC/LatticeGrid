
def CurrentJournals
  journals = Abstract.all.collect{|a| a.journal_abbreviation.downcase}.sort.uniq
end

def JournalsWithMismatchedISSNs
  journals = Abstract.mismatched_issns
end

def AllJournalsWithImpact
  journals = Journal.all.collect{|a| a.journal_abbreviation.downcase}.sort.uniq
end

def CurrentJournalsWithImpactScore(journals)
  journals_w_scores = Journal.journals_with_scores(journals)
end

def UpdateJournalHighImpactPreferred
  pref_issns = LatticeGridHelper.high_impact_issns
  all_high_impact = Journal.high_impact_issns
  current_preferred_issns = Journal.all(:conditions=>"include_as_high_impact = true")
  puts "Preferred: #{pref_issns.length}; all high impact #{all_high_impact.length}; current_preferred: #{current_preferred_issns.length}."
  current_preferred_issns.each do |pref|
    pref.include_as_high_impact = false
    pref.save!
  end
  puts "current preferred high impact journals reset (#{current_preferred_issns.length} journals reset)"
  issns_found = Journal.all(:conditions=>["issn IN (:issns)", {:issns=>pref_issns }])
  puts "pref_issns: #{pref_issns.length}; found issns: #{issns_found.length}"
  issns_found.each do |pref|
    pref.include_as_high_impact = true
    pref.save!
  end
  puts "updating!"
  current_preferred_issns = Journal.all(:conditions=>"include_as_high_impact = true")
  puts "Preferred: #{pref_issns.length}; all high impact #{all_high_impact.length}; current_preferred: #{current_preferred_issns.length}."

end

def CreateJournalImpactFromHash(data_row)
  # assumed header values
  #Abbreviated Journal Title
  #ISSN
  #{year} Total Cites
  #Impact Factor
  #5-Year Impact Factor
  #Immediacy Index
  #{year} Articles
  #Cited Half-Life
  #Eigenfactor Score
  #Article Influence Score

  # get smarter to pull out impact factor year. Right now it is encoded in the ISI file in the heading Total_Cites as '{year} Total Cites'
  j = Journal.new
  j.score_year = 2008
  data_row.headers.each do |header|
    if header =~ /[0-9]+/
      j.score_year = $&
      break
    end
  end
  j.journal_abbreviation =  data_row['Abbreviated Journal Title']
  j.jcr_journal_abbreviation =  data_row['Abbreviated Journal Title']
  j.issn = data_row['ISSN']
  j.total_cites = data_row["{#{j.score_year}} Total Cites"]
  j.impact_factor = data_row['Impact Factor']
  j.impact_factor_five_year = data_row['5-Year Impact Factor']
  j.immediacy_index = data_row['Immediacy Index']
  j.total_articles = data_row["{#{j.score_year}} Articles"]
  j.eigenfactor_score = data_row['Eigenfactor Score']
  j.article_influence_score = data_row['Article Influence Score']

  if ! j.issn.blank?
    existing_j = Journal.find_by_issn(j.issn)
  end
  if existing_j.blank? and ! j.jcr_journal_abbreviation.blank?
    existing_j = Journal.find_by_jcr_journal_abbreviation(j.jcr_journal_abbreviation)
  end
  if existing_j.blank? && (! j.issn.blank? or ! j.jcr_journal_abbreviation.blank? ) then
    j.save!
  else
    existing_j.journal_abbreviation = existing_j.journal_abbreviation || j.journal_abbreviation
    existing_j.jcr_journal_abbreviation = existing_j.jcr_journal_abbreviation || j.jcr_journal_abbreviation
    existing_j.issn = existing_j.issn || j.issn
    existing_j.total_cites = j.total_cites
    existing_j.impact_factor = j.impact_factor
    existing_j.impact_factor_five_year = j.impact_factor_five_year
    existing_j.immediacy_index = j.immediacy_index
    existing_j.eigenfactor_score = j.eigenfactor_score
    existing_j.article_influence_score = j.article_influence_score
    existing_j.score_year = j.score_year
    existing_j.save!
  end
end

def UpdateJournalAbbreviation(data_row)
  # assumed header values
  #Abbreviated Journal Title
  #ISO Abbreviated Journal Title
  journal_abbreviation =  data_row['ISO Abbreviated Journal Title']
  jcr_journal_abbreviation =  data_row['Abbreviated Journal Title']
  j = Journal.find_by_jcr_journal_abbreviation(jcr_journal_abbreviation)
  if ! jcr_journal_abbreviation.blank?  && ! journal_abbreviation.blank? && ! j.blank? then
    puts "updating journal with jcr_journal_abbreviation=#{jcr_journal_abbreviation} and iso abbreviation #{journal_abbreviation} " if LatticeGridHelper.verbose?
    j.journal_abbreviation=journal_abbreviation
    j.jcr_journal_abbreviation=jcr_journal_abbreviation
    j.save
  end
end

def UpdateJournalISSNsFromPubmed
  mismatches = Journal.match_by_abbrev
  # two types - ISSN does not match from Pubmed central, ISSN in pubmed entry is unset
  puts "#{mismatches.length} mismatches found"
  mismatches.each do |mismatch|
    if mismatch.pubmed_issn.blank?
      puts "pubmed_issn blank for journal #{mismatch.journal_abbreviation} replaced with #{mismatch.issn}"
      Abstract.update_all({:issn => mismatch.issn}, ['lower(journal_abbreviation) = :journal_abbrev', {:journal_abbrev => mismatch.journal_abbreviation.downcase}])
    else
      # update the ISSN in the Journal record since it is not found in any other record.
      puts "pubmed ISSN #{mismatch.pubmed_issn} for journal #{mismatch.journal_abbreviation} added to ISI JCR entry formerly #{mismatch.issn}"
      Journal.update_all({:issn => mismatch.pubmed_issn}, ['lower(journal_abbreviation) = :journal_abbrev', {:journal_abbrev => mismatch.journal_abbreviation.downcase}])
    end
  end
end