# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'Investigators' do

  context 'with data' do
    let(:last_name) { 'Jones' }
    let!(:pi) { FactoryGirl.create(:investigator, first_name: 'George', last_name: last_name, username: 'geojones') }

    # GET /investigators/:username/show/1
    describe 'visiting the investigator page', js: true do

      it 'renders the page' do
        visit "/investigators/#{pi.username}/show/1"

        expect(page).to have_content("#{pi.full_name}")
        # print page.html
      end
    end

    # GET /investigators/:keyword/investigators_search?keywords=:keyword
    describe 'visiting the investigator search page', js: true do
      context 'with two investigators with the same last name' do
        let!(:pi2) { FactoryGirl.create(:investigator, first_name: 'Martha', last_name: last_name, username: 'mjones') }
        it 'renders the search results page' do
          visit "/investigators/#{last_name}/investigators_search?keywords=#{last_name}"
          # TODO: assert template to confirm page rendered
          expect(page).to have_content('There were 2 matches to search term jones')
          expect(page).to have_content(pi.display_name_with_degrees)
          expect(page).to have_content(pi2.display_name_with_degrees)
        end
      end

      context 'with one investigator matching search term' do
        it 'renders the investigator show page' do
          visit "/investigators/#{last_name}/investigators_search?keywords=#{last_name}"
          # TODO: assert template to confirm page rendered
          expect(page).to have_content("#{pi.full_name}")
        end
      end
    end
  end
end
