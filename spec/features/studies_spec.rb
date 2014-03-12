# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'Studies' do
  # print page.html

  context 'with data' do
    let(:study) { FactoryGirl.create(:study) }
    let(:department) { FactoryGirl.create(:department) }
    let(:pi) { FactoryGirl.create(:investigator) }
    let!(:investigator_study) { FactoryGirl.create(:investigator_study, investigator: pi, study: study, role: 'PI') }
    let!(:investigator_appointment) { FactoryGirl.create(:primary_member, investigator: pi, organizational_unit: department) }

    # GET /studies/:organizational_unit_id/org?page=1
    describe 'visiting the organizational unit show investigators page' do
      it 'renders the page' do
        visit "/studies/#{department.id}/org?page=1"
        expect(page).to have_content("#{department.name} Clinical Research Study Overview")
        expect(page).to have_content('Number of Clinical Research Studies: 1')
        expect(page).to have_content("#{pi.name}")
      end
    end
  end
end
