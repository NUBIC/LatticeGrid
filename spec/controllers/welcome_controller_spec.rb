# -*- coding: utf-8 -*-
require 'spec_helper'

describe WelcomeController do

  let(:abstract) { FactoryGirl.create(:abstract) }
  let(:pi) { FactoryGirl.create(:investigator) }
  let!(:pub) { FactoryGirl.create(:investigator_abstract, investigator: pi, abstract: abstract) }

  describe 'GET search' do
    describe 'with Investigator search_field value' do
      it 'redirects to the investigators_search_investigator_path' do
        get :search, keywords: pi.last_name, search_field: 'Investigator'
        response.should redirect_to investigators_search_investigator_path(id: pi.last_name, keywords: pi.last_name)
      end
    end

    describe 'with AllByInvestigator search_field value' do
      it 'redirects to the investigators_search_all_path' do
        get :search, keywords: pi.last_name, search_field: 'AllByInvestigator'
        response.should redirect_to investigators_search_all_path(id: pi.last_name, keywords: pi.last_name, search_field: 'AllByInvestigator')
      end
    end

    describe 'with Keywords search_field value' do
      it 'redirects to the abstracts_search_path' do
        get :search, keywords: 'asdf', search_field: 'Keywords'
        response.should redirect_to abstracts_search_path(keywords: 'asdf', search_field: 'Keywords')
      end
    end

    describe 'without a search_field value' do
      it 'redirects to the abstracts_search_path' do
        get :search, keywords: 'asdf'
        response.should redirect_to abstracts_search_path(keywords: 'asdf')
      end
    end
  end
end
