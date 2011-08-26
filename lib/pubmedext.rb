require 'bio/db'

module Bio

  class MEDLINE < NCBIDB

    # MHDA   - MeSH line Date
    #   The date the article was published.
    def mhda
    @pubmed['MHDA'].strip
    end


    # DEP   - Deposited Date
    #   The date the article was deposited in pubmed.
    def dep
    @pubmed['DEP'].strip  # in the form 20070802
    end
    alias deposited_date dep

    # EDAT   - Electronic Publication Date
    #   The date the article was released electronically in pubmed.
    def edat
     @pubmed['EDAT'].strip  # in the form 20070802
    end
    alias electronic_publication_date edat

    # STAT   - status
    #   Current status of the record
    def stat
    @pubmed['STAT'].strip
    end
    alias status stat

    # DP   - Publication Date
    #   The date the article was published. Year MON day
    def publication_date
     pubdate=@pubmed['DP'].strip.split(" ")
     if pubdate.length > 2
       pubdate[2].to_s + '-' + pubdate[1].to_s + '-' + pubdate[0].to_s
     elsif pubdate.length == 2
       '01-'+ pubdate[1]+'-'+ pubdate[0]
     elsif pubdate.length == 1
       '01-JAN-'+ pubdate[0]
     else
       nil
     end
    end


    # PST   - Publication Status
    #   The date the article was published.
    def pst
      @pubmed['PST'].strip
    end
    alias publication_status pst

    # FAU   - Full Author Name
    #   Authors' names.
    def fau
        @pubmed['FAU'].strip
    end
    alias full_authors fau

    # JT - Journal Title - full text title
    def jt
        @pubmed['JT'].strip
    end
    alias full_journal jt

    # PMC - Pubmed central ID
    def pmc
        @pubmed['PMC'].strip
    end

    # IS - ISSN for linking
    # "IS"=>"1520-4995 (Electronic)\n0006-2960 (Linking)\n"
    def issn
      issn = @pubmed['IS'].strip
      if ! issn.blank?
        issn_array=issn.split("\n")
        issn = ""
        issn_array.each do |issn_item|
          if issn_item =~ /linking/i
            issn_item =~ /([0-9]+-[0-9]+[0-9X])/
            issn = $&
            break
          end
        end
      end
      issn
    end

    alias pmcid pmc
    alias pubmed_central pmc
  end
end