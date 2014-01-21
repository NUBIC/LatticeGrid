# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'Abstracts' do

  ##
  # The index page at public/index.html through javascript
  # replaces the window.location in effect redirecting the
  # user to /abstracts/current which in turn redirects the
  # user to the abstracts_by_year_url - /abstracts/:year/year_list/:page
  # after handling the determination of the year.
  # @see AbstractsController#handle_year
  describe 'visiting the home page', js: true do

    it 'gives context about the publications' do
      visit '/'
      expect(page).to have_content('LatticeGrid Publications and Abstracts Site')
      expect(page).to have_content("Publication Listing for #{Time.now.year}")
      expect(page).to have_content("MeSH cloud from publications for the year #{Time.now.year}")
    end

    describe 'without any publications' do
      it 'shows the user that there are no publications' do
        visit '/'
        expect(page).to have_content("Publication Listing for #{Time.now.year} (0 publications)")
        expect(page).to have_content('Sorry, no publications are available!')
      end
    end

    ##
    # AbstractsController#year_list gets the data to display
    # throught the model method Abstract.display_data.
    # @see AbstractsController#year_list
    # @see Abstract.display_data
    describe 'with publication(s)' do

      ##
      # Create Abstract record(s) that will return data from
      # the query in Abstract.display_data.
      # Note that the investigator_abstract.is_valid must be true
      # and abstracts.is_valid must also be true
      # and abstracts requires authors and pages fields to be populated
      let(:pi)  { FactoryGirl.create(:investigator,
                                      last_name: 'last_name',
                                      first_name: 'first_name') }
      let(:pub) { FactoryGirl.create(:abstract,
                                      year: Time.now.year.to_s,
                                      is_valid: true,
                                      authors: 'last_name, f.',
                                      full_authors: 'last_name, first_name') }
      before do
        FactoryGirl.create(:investigator_abstract, investigator: pi, abstract: pub, is_valid: true)
      end

      it 'shows the user the publications for the current year' do
        visit '/'
        expect(page).to have_content("Publication Listing for #{Time.now.year} (1 publications)")
      end
    end
  end

end
