def quicklink_to_pubmed(pubmed_id)
  return nil if pubmed_id.blank?
  link_to( pubmed_id, "http://www.ncbi.nlm.nih.gov/pubmed/"+pubmed_id, :target => '_blank', :title=>'link to PubMed entry') 
end
  
def quicklink_to_pubmedcentral(pmc_id)
  return nil if pmc_id.blank?
  link_to( pmc_id, "http://www.ncbi.nlm.nih.gov/pmc/articles/"+pmc_id, :target => '_blank', :title=>'link to PubMed Central') 
end
  
def quicklink_to_doi(doi)
  return nil if doi.blank?
  link_to( doi, "http://dx.doi.org/"+doi, :target => '_blank', :title=>'link to DOI entry') 
end
  
