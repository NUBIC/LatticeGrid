# -*- coding: utf-8 -*-
require 'spec_helper'

describe AdminController do
  context 'without an authenticated user' do
    describe 'GET /index' do
      it 'redirects to the login page' do
        LatticeGridHelper.stub!(:require_authentication).and_return(true)
        get :index
        response.should be_redirect
      end
    end
  end

  context 'with an authenticated admin user' do
    before(:each) do
      login(admin_login)
    end

    describe 'GET /index' do
      it 'works' do
        get :index
        response.should be_success
      end
    end
  end
end
