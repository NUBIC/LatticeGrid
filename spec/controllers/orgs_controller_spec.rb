# -*- coding: utf-8 -*-
require 'spec_helper'

describe OrgsController do
  before do
    OrganizationalUnit.rebuild!
    FactoryGirl.create(:program, abbreviation: 'head_node', department_id: 666, division_id: 999)
  end

  let(:head_node) { OrganizationalUnit.head_node('head_node') }

  describe 'GET index' do
    it 'renders template and assigns @units and @heading' do
      get :index
      response.should render_template('index')
      assigns[:units].should_not be_nil
      assigns[:heading].should_not be_nil
    end
  end

  describe 'GET show' do
    it 'renders template and assigns @abstracts' do
      get :show, { id: head_node.id, page: '1' }
      response.should render_template('show')
      assigns[:abstracts].should_not be_nil
    end
  end
end
