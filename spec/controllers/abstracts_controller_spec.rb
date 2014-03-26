# -*- coding: utf-8 -*-
require 'spec_helper'

describe AbstractsController do
  context 'without data' do
    let(:year) { LatticeGridHelper.year_array.first.to_s }
    describe 'GET index' do
      it 'redirects to abstracts_by_year' do
        get :index
        response.should redirect_to(abstracts_by_year_path(id: year, page: '1'))
      end
    end
    describe 'GET year_list' do
      it 'redirects to abstracts_by_year' do
        get :year_list, id: year
        response.should redirect_to(abstracts_by_year_path(id: year, page: '1'))
      end
    end
  end

  context 'with organizational unit data' do
    before do
      OrganizationalUnit.rebuild!
      ou = FactoryGirl.create(:program, abbreviation: 'head_node', department_id: 666, division_id: 999)
      FactoryGirl.create(:organization_abstract, organizational_unit: ou)
    end
    let(:year) { LatticeGridHelper.year_array.first.to_s }
    let(:abstract) { Abstract.first }
    let(:journal) { FactoryGirl.create(:journal) }
    describe 'GET year_list' do
      it 'renders template and assigns variables' do
        get :year_list, id: year, page: '1'
        response.should render_template('year_list')
        assigns[:abstracts].should_not be_nil
      end
    end
    describe 'GET current' do
      it 'redirects to abstracts_by_year' do
        get :current
        response.should redirect_to(abstracts_by_year_path(id: year, page: '1'))
      end
    end
    describe 'GET show' do
      it 'renders template and assigns variables' do
        get :show, id: abstract.id
        response.should render_template('show')
        assigns[:publication].should_not be_nil
        assigns[:publication].should be_valid
      end
    end
    describe 'GET journal_list' do
      it 'renders template and assigns variables' do
        get :journal_list, id: journal.id
        response.should render_template('journal_list')
        assigns[:abstracts].should_not be_nil
      end
    end
    describe 'GET high_impact' do
      it 'renders template and assigns variables' do
        get :high_impact
        response.should render_template('high_impact')
        assigns[:high_impact].should_not be_nil
      end
    end
    describe 'GET impact_factor' do
      it 'renders template and assigns variables' do
        get :impact_factor, id: Time.now.year.to_s
        response.should render_template('impact_factor')
        assigns[:journals].should_not be_nil
        assigns[:missing_journals].should_not be_nil
        assigns[:high_impact_pubs].should_not be_nil
        assigns[:all_pubs].should_not be_nil
      end
    end
    describe 'GET year_list' do
      it 'needs an id and page or it is redirected' do
        get :year_list, id: year, page: '1'
        response.should render_template('year_list')
        assigns[:abstracts].should_not be_nil

        get :year_list, id: '2007'
        response.should redirect_to(abstracts_by_year_path(id: '2007', page: '1'))

        get :year_list, id: '2008'
        response.should redirect_to(abstracts_by_year_path(id: '2008', page: '1'))
      end
    end
    describe 'GET full_year_list' do
      it 'renders template and assigns variables' do
        get :full_year_list, id: '2009'
        response.should render_template('year_list')
        assigns[:abstracts].should_not be_nil
      end
    end
    describe 'GET tag_cloud' do
      it 'renders template and assigns variables' do
        get :tag_cloud
        response.should render_template('tag_cloud')
        assigns[:tags].should_not be_nil
      end
    end
    describe 'GET tagged_abstracts' do
      it 'renders template and assigns variables' do
        get :tagged_abstracts,  id: 'disease', page: '1'
        response.should render_template('tag')
        assigns[:abstracts].should_not be_nil
      end
      it 'redirects to the tagged_abstracts_abstract_path' do
        get :tagged_abstracts,  id: 'disease'
        response.should redirect_to tagged_abstracts_abstract_path(id: 'disease', page: '1')
      end
    end
    describe 'GET full_tagged_abstracts' do
      it 'renders template and assigns variables' do
        get :full_tagged_abstracts, id: 'disease', page: '1'
        response.should render_template('tag')
        assigns[:abstracts].should_not be_nil
      end
    end
  end
end
