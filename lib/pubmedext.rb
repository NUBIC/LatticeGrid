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

    # CRDT   - Creation Date
    #   The date the article was first published in pubmed.
    def crdt
     @pubmed['CRDT'].strip  # in the form 2005/06/10
    end
    alias creation_date crdt

    # STAT   - status
    #   Current status of the record
    def stat
    @pubmed['STAT'].strip
    end
    alias status stat

    # DP   - Publication Date
    #   The date the article was published. Year MON day
    # tough case:  "2007 Dec-2008 Jan"
    # another case "2005 Apr 16-22"
  def publication_date
    the_date = nil
    return the_date if @pubmed['DP'].blank?
    if @pubmed['DP'].strip =~ /([0-9][0-9][0-9][0-9] [a-zA-Z]+)-([0-9][0-9][0-9][0-9] [a-zA-Z]+)/i
      @pubmed['DP'] =  @pubmed['DP'].strip.split("-")[1]
    end
    if @pubmed['DP'].strip =~ /([0-9][0-9][0-9][0-9]) ([a-zA-Z]+ [0-9]+)-([a-zA-Z]+ [0-9]+)/i
      @pubmed['DP'] =  @pubmed['DP'].strip.gsub(/([0-9][0-9][0-9][0-9]) ([a-zA-Z]+ [0-9]+)-([a-zA-Z]+ [0-9]+)/i, '\1 \3')
    end
    pubdate=@pubmed['DP'].strip.split(" ")
    year_range = pubdate[0].split("-")
    if year_range.length > 1
      pubdate[0] = year_range[1]
    end
    if pubdate.length > 1
      month_range = pubdate[1].split("-")
      if month_range.length > 1
        pubdate[1] = month_range[1]
      end
      pubdate[1] = case pubdate[1] 
        when /spring/i then 'Mar'
        when /summer/i then 'Jun'
        when /fall|autumn/i then 'Sep'
        when /winter/i then 'Dec'
        else pubdate[1]
      end
    end
    if pubdate.length > 2
      day_range = pubdate[2].split("-")
      if day_range.length > 1
        pubdate[2] = day_range[1]
      end
      the_date = pubdate[2].to_s + '-' + pubdate[1].to_s + '-' + pubdate[0].to_s
    elsif pubdate.length == 2
      the_date = '01-'+ pubdate[1]+'-'+ pubdate[0]
    elsif pubdate.length == 1
      the_date = '01-JAN-'+ pubdate[0]
    end
    return the_date
  end

    def dp
     @pubmed['DP'].strip
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