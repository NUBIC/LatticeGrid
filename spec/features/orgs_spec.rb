# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'Organizational Units' do
  # print page.html
  context 'with data' do
    let!(:center) { FactoryGirl.create(:center) }
    let!(:department) { FactoryGirl.create(:department) }

    # GET orgs/:organizational_unit_id/show_investigators
    describe 'visiting the organizational unit show investigators page' do
      it 'renders the page' do
        visit "/orgs/#{department.id}/show_investigators"
        expect(page).to have_content("Faculty Listing for '#{department.name}'")
        expect(page).to have_content("MeSH cloud from publications in #{department.name}")
      end
    end

    # GET orgs/:organizational_unit_id/show/1
    describe 'visiting the organizational unit show page' do
      it 'renders the page' do
        visit "/orgs/#{department.id}/show/1"
        expect(page).to have_content("#{department.name} Overview")
        expect(page).to have_content("MeSH cloud from publications by faculty members in #{department.name}")
      end
    end

    # GET /orgs/departments
    describe 'visiting the orgs departments page' do
      it 'renders the page' do
        visit '/orgs/departments'
        expect(page).to have_content 'Current Department Listing'
      end
    end

    # GET /orgs/centers
    describe 'visiting the orgs centers page' do
      it 'renders the page' do
        visit '/orgs/centers'
        expect(page).to have_content 'Current Center Listing'
      end
    end
  end
end
