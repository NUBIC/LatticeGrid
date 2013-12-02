# -*- coding: utf-8 -*-
require 'spec_helper'

describe InvestigatorsController do
  let(:pi) { FactoryGirl.create(:investigator) }
  describe 'GET listing' do
    it 'renders template and assigns @investigators' do
      get :listing, :id => pi.id
      response.should render_template('listing')
      assigns[:investigators].should_not be_nil
    end
  end
end
