# -*- coding: utf-8 -*-
require 'spec_helper'
require 'cytoscape_generator'
require 'cytoscape_publications'
require 'cytoscape_awards'
require 'pubmed_utilities'
require 'mesh_utilities'
include ApplicationHelper

describe 'CytoscapeGenerator' do

  context 'for Organizational Units' do
    # create two Investigators (PI)
    let!(:pi) { FactoryGirl.create(:investigator, username: 'pi', first_name: 'Principal', last_name: 'Investigator') }
    let!(:co) { FactoryGirl.create(:investigator, username: 'co', first_name: 'Co', last_name: 'Investigator') }
    # and an OrganizationalUnit (OU)
    let!(:center) { FactoryGirl.create(:center) }
    # then associate them with the OU
    let!(:pi_appt) { FactoryGirl.create(:investigator_appointment, investigator: pi, center: center) }
    let!(:co_appt) { FactoryGirl.create(:investigator_appointment, investigator: co, center: center) }

    describe '.generate_cytoscape_org_data' do
      it 'outputs a hash of nodes and edges' do
        hsh = generate_cytoscape_org_data(center, 1, 1, 0, 0)
        nodes = hsh[:nodes]
        nodes.size.should eq 3 # the 1 ou + the 2 pis
        assert_ou_node(nodes[0])
        assert_publication_node(nodes[1], co, 1)
        assert_publication_node(nodes[2], pi, 1)

        edges = hsh[:edges]
        edges.size.should eq 2
        assert_ou_edge(edges[0], co.id)
        assert_ou_edge(edges[1], pi.id)
      end

    end

  end

  context 'for Investigators' do
    # create two Investigators (PI)
    let!(:pi) { FactoryGirl.create(:investigator, username: 'pi', first_name: 'Principal', last_name: 'Investigator') }
    let!(:co) { FactoryGirl.create(:investigator, username: 'co', first_name: 'Co', last_name: 'Investigator') }
    # and a publication, study, and award
    let!(:ab) { FactoryGirl.create(:abstract) }
    let!(:aw) { FactoryGirl.create(:proposal, institution_award_number: 'institution_award_number') }
    let!(:st) { FactoryGirl.create(:study, irb_study_number: 'irb_study_number') }

    before do
      # set up publication associations so that both are authors on this abstract
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
      it 'outputs a hash of nodes and edges' do
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
      it 'outputs an array of publication node hashes' do
        pi.abstracts.size.should eq 1
        nodes = generate_cytoscape_publication_nodes(pi, 1)
        nodes.size.should eq 2
        assert_publication_node(nodes.first)
      end
    end

    describe '.generate_cytoscape_award_nodes' do
      it 'outputs an array of publication and award hashes' do
        pi.proposals.size.should eq 1
        arr = generate_cytoscape_award_nodes(pi, 1)
        arr.size.should eq 2
        assert_publication_node(arr.first)
        assert_award_node(arr.last)
      end
    end

    describe '.generate_cytoscape_study_nodes' do
      it 'outputs an array of publication and study hashes' do
        pi.studies.size.should eq 1
        arr = generate_cytoscape_study_nodes(pi, 1)
        arr.size.should eq 2
        assert_publication_node(arr.first)
        assert_study_node(arr.last)
      end
    end
  end

  context 'data schema' do
    describe '.generate_cytoscape_schema' do
      it 'returns a hash with keys :nodes and :edges' do
        schema = generate_cytoscape_schema
        schema.size.should be 2
        schema.keys.should eq [:nodes, :edges]
        nodes = schema[:nodes]
        nodes.size.should be 6

        node_names = %w(label element_type tooltiptext weight depth mass)
        node_name_map = nodes.map { |n| n[:name] }
        node_name_map.should eq node_names
        node_types = %w(string string string number number long)
        node_type_map = nodes.map { |n| n[:type] }
        node_type_map.should eq node_types

        edges = schema[:edges]
        edges.size.should be 5

        edge_names = %w(label element_type tooltiptext weight directed)
        edge_name_map = edges.map { |n| n[:name] }
        edge_name_map.should eq edge_names
        edge_types = %w(string string string long boolean)
        edge_type_map = edges.map { |n| n[:type] }
        edge_type_map.should eq edge_types
      end
    end
  end

  def assert_edge(edge)
    ic = pi.investigator_colleagues.first
    edge[:id].should eq '0'
    edge[:label].should eq ic.publication_cnt.to_s
    edge[:tooltiptext].should eq investigator_colleague_edge_tooltip(ic, pi, co)
    edge[:source].should eq pi.id.to_s
    edge[:target].should eq co.id.to_s
    edge[:element_type].should eq 'Publication'
    edge[:weight].should eq 1
  end

  def assert_ou_node(node, depth = 0)
    node[:id].should eq "org_#{center.id}"
    node[:element_type].should eq 'Org'
    node[:label].should eq center.name
    node[:tooltiptext].should eq org_node_tooltip(center, depth)
    node[:weight].should eq 0 # number of publications?
    node[:depth].should eq depth
  end

  def assert_ou_edge(edge, target)
    edge[:source].should eq "org_#{center.id}"
    edge[:target].should eq target.to_s
    edge[:element_type].should eq 'Org'
    edge[:tooltiptext].should eq 'member of center'
    edge[:weight].should eq 1
    edge[:label].should be_blank
  end

  def assert_publication_node(node, i = pi, depth = 0)
    node[:id].should eq i.id.to_s
    node[:element_type].should eq 'Investigator'
    node[:label].should eq i.name
    node[:tooltiptext].should eq investigator_tooltip(i, depth)
    node[:mass].should eq node[:weight]
    node[:depth].should eq depth
  end

  def assert_award_node(node, depth = 1)
    node[:id].should eq "A_#{aw.id}"
    node[:element_type].should eq 'Award'
    node[:label].should eq aw.institution_award_number
    node[:tooltiptext].should eq award_tooltip(aw, depth)
    node[:weight].should eq 10 # default
    node[:depth].should eq depth
  end

  def assert_study_node(node, depth = 1)
    node[:id].should eq "S_#{st.id}"
    node[:element_type].should eq 'Study'
    node[:label].should eq st.irb_study_number
    node[:tooltiptext].should eq study_tooltip(st, depth)
    node[:weight].should eq 1 # default
    node[:depth].should eq depth
  end

end