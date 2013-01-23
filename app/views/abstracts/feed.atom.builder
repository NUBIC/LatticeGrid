atom_feed( :url => formatted_abstracts_url(:atom)) do |feed|

  feed.title(@title)
  feed.updated(@updated)

  for abs in @abstracts
    feed.entry(abs) do |entry|
      entry.url abstract_url(abs)
      entry.title(abs.title)
      entry.subtitle(abs.authors)
      entry.content(abs.abstract, :type => 'html')
      entry.updated abs.updated_at
      # the strftime is needed to work with Google Reader.
      #entry.updated(abs.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name(abs.authors)
      end
    end
  end
end
