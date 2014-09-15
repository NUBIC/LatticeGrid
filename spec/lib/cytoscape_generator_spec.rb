# -*- coding: utf-8 -*-
require 'spec_helper'
require 'cytoscape_generator'
require 'cytoscape_publications'
require 'cytoscape_awards'
require 'pubmed_utilities'
require 'mesh_utilities'
include ApplicationHelper

describe 'CytoscapeGenerator' do

  let!(:pi) { FactoryGirl.create(:investigator, username: 'pi', first_name: 'Principal', last_name: 'Investigator') }
  let!(:co) { FactoryGirl.create(:investigator, username: 'co', first_name: 'Co', last_name: 'Investigator') }
  let!(:ab) { FactoryGirl.create(:abstract) }
  let!(:aw) { FactoryGirl.create(:proposal, institution_award_number: 'institution_award_number') }
  let!(:st) { FactoryGirl.create(:study, irb_study_number: 'irb_study_number') }

  before do
    # set up publication associations
    FactoryGirl.create(:investigator_abstract, investigator: pi, abstract: ab, is_valid: true)
    FactoryGirl.create(:investigator_abstract, investigator: co, abstract: ab, is_valid: true)

    # cf. pubmed_utilities to see what these do
    UpdateInvestigatorCitationInformation(pi)
    UpdateInvestigatorCitationInformation(co)
    BuildInvestigatorColleague(pi, co, false)

    # set up award associations
    FactoryGirl.create(:investigator_proposal, investigator: pi, proposal: aw, role: 'PD/PI', is_main_pi: true)

    # set up study associations
    FactoryGirl.create(:investigator_study, investigator: pi, study: st, role: 'PI')
  end

  describe '.generate_cytoscape_data' do
    it 'outputs a hash' do
      hsh = generate_cytoscape_data(pi, 1, 1, 0, 0) # does not include awards or studies
      nodes = hsh[:nodes]
      nodes.size.should eq 2
      assert_publication_node(nodes.first)

      edges = hsh[:edges]
      edges.size.should eq 1
      assert_edge(edges.first)
    end
  end

  describe '.generate_cytoscape_publication_nodes' do
    it 'outputs an array of hashes' do
      pi.abstracts.size.should eq 1
      nodes = generate_cytoscape_publication_nodes(pi, 1)
      nodes.size.should eq 2
      assert_publication_node(nodes.first)
    end
  end

  describe '.generate_cytoscape_award_nodes' do
    it 'outputs an array of hashes' do
      pi.proposals.size.should eq 1
      arr = generate_cytoscape_award_nodes(pi, 1)
      arr.size.should eq 2
      assert_publication_node(arr.first)
      assert_award_node(arr.last)
    end
  end

  describe '.generate_cytoscape_study_nodes' do
    it 'outputs an array of hashes' do
      pi.studies.size.should eq 1
      arr = generate_cytoscape_study_nodes(pi, 1)
      arr.size.should eq 2
      assert_publication_node(arr.first)
      assert_study_node(arr.last)
    end
  end

  def assert_edge(edge)
    ic = pi.investigator_colleagues.first
    edge[:id].should eq '0'
    edge[:label].should eq ic.publication_cnt.to_s
    edge[:tooltiptext].should eq investigator_colleague_edge_tooltip(ic, pi, co)
    edge[:source].should eq pi.id.to_s
    edge[:target].should eq co.id.to_s
  end

  def assert_publication_node(node)
    node[:id].should eq pi.id.to_s
    node[:element_type].should eq 'Investigator'
    node[:label].should eq pi.name
    node[:tooltiptext].should eq investigator_tooltip(pi, 0)
  end

  def assert_award_node(node)
    node[:id].should eq "A_#{aw.id}"
    node[:element_type].should eq 'Award'
    node[:label].should eq aw.institution_award_number
    node[:tooltiptext].should eq award_tooltip(aw, 1)
  end

  def assert_study_node(node)
    node[:id].should eq "S_#{st.id}"
    node[:element_type].should eq 'Study'
    node[:label].should eq st.irb_study_number
    node[:tooltiptext].should eq study_tooltip(st, 1)
  end

end