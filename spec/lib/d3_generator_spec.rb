# -*- coding: utf-8 -*-
require 'spec_helper'
require 'd3_generator'
require 'pubmed_utilities'
require 'publication_utilities'
require 'mesh_utilities'
include ApplicationHelper

describe 'd3Generator' do
  # create two Investigators (PI)
  let!(:pi) { FactoryGirl.create(:investigator, username: 'pi', first_name: 'Principal', last_name: 'Investigator') }
  let!(:co) { FactoryGirl.create(:investigator, username: 'co', first_name: 'Co', last_name: 'Author') }
  # and a hierarchy of OrganizationalUnits (OU) - school has two departments
  let!(:school) { FactoryGirl.create(:school, name: 'school', department_id: '100000', division_id: '100010') }
  let!(:dept1) { FactoryGirl.create(:department, name: 'dept1', department_id: '101000', division_id: '101010', abbreviation: 'dept1') }
  let!(:dept2) { FactoryGirl.create(:department, name: 'dept2', department_id: '102000', division_id: '102010', abbreviation: 'dept2') }
  # then associate each PI with the sub-OU
  let!(:pi_appt) { FactoryGirl.create(:primary_member, investigator: pi, organizational_unit: dept1) }
  let!(:co_appt) { FactoryGirl.create(:primary_member, investigator: co, organizational_unit: dept2) }
  # create some words for the investigator wordle 
  let(:abstract_text) { 'Mixed cultures of astrocytes and oligodendrocytes derived from cerebral hemispheres of 18-19 day old rat fetuses were studied with the freeze-fracture technique. The plasma membranes of cultured astrocytes and oligodendrocytes differ substantially in their intramembrane particle profiles, and they can be positively identified consistently. Orthogonal small particle assemblies and numerous isolated globular particles characterize astrocytic plasma membranes, whereas the plasma membranes of oligodendrocytes show numerous elongated particles and fewer large and small globular particles similar to those seen in situ. Using these distinct differential features, we can identify partners of glial cell junctions. We can identify numerous interastrocytic gap junctions, as well as heterologous astrocyte-to-oligodendrocyte gap junctions. The plasma membranes of adjacent oligodendrocytes form numerous tight junctions consisting of linear P face strands and/or rows of particles interrupted by short segments of grooves, the complementary features on the E face. \"Reflexive\" type tight junctions seen in situ are also observed. In addition to intercellular junctions, glial cells develop special plasma membrane structural domains. Astrocytic plasma membranes often contain groups of plasmalemmal vesicles (caveolae), a distinctive feature of astrocytes in situ. Oligodendrocytes form flattened velate processes with cytoplasm restricted to finger-like channels resembling myelin lamellae in situ. Cultured astrocytes and oligodendrocytes develop the entire range of plasma membrane structural specializations seen in situ in the absence of the normal brain tissue framework. Thus, primary glial cell cultures allow experimental study of many glial cell properties, including their plasma membrane specializations.' }
  let(:abstract_title) { 'Cell-cell junctional interactions and characteristic plasma membrane features of cultured rat glial cells.' }
  # and put them in a publication
  let!(:ab) { FactoryGirl.create(:abstract, abstract: abstract_text, title: abstract_title) }
  let!(:aw) { FactoryGirl.create(:proposal, institution_award_number: 'institution_award_number') }
  let!(:st) { FactoryGirl.create(:study, irb_study_number: 'irb_study_number') }

  before do
    # set up nested set relationship
    # cf. CleanUpOrganizationData in lib/organization_utilities.rb
    dept1.parent_id = school.id
    dept1.move_to_child_of school
    dept1.save!

    dept2.parent_id = school.id
    dept2.move_to_child_of school
    dept2.save!

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

    # create the organization abstract records
    # cf. lib/publication_utilities.rb#UpdateOrganizationAbstract
    [dept1, dept2].each do |unit|
      unit_id = unit.id
      investigators = OrganizationalUnit.find(unit_id).primary_faculty + OrganizationalUnit.find(unit_id).associated_faculty
      abstracts = Abstract.all_investigator_publications(investigators.map(&:id)).uniq
      abstracts.each { |abstract| UpdateOrganizationAbstract(unit_id, abstract.id) }
    end
  end

  describe '.d3_master_investigator_graph' do
    it 'outputs an array' do
      graph = d3_master_investigator_graph(pi)
      graph.size.should eq 2
      assert_investigator_graph(graph[0], pi, co)
      assert_investigator_graph(graph[1], co, pi)
    end
  end

  describe '.d3_all_units_graph' do
    it 'outputs an array of hashes of both org units and their investigators' do
      units = school.descendants
      units.size.should eq 2

      graph = d3_all_units_graph(units)
      graph.size.should eq 4 # 2 departments and 2 PIs

      assert_department_graph(graph[0], dept1)
      assert_investigator_graph(graph[1], pi, co, true)
      assert_department_graph(graph[2], dept2)
      assert_investigator_graph(graph[3], co, pi, true)
    end
  end

  describe '.d3_all_investigators_graph' do
    context 'for the whole school' do
      it 'outputs an array of /all/ investigators (i.e. all departments)' do
        graph = d3_all_investigators_graph(school)
        graph.size.should eq 2
        assert_investigator_graph(graph[0], co, pi)
        assert_investigator_graph(graph[1], pi, co)
      end
    end
    context 'per department' do
      it 'outputs an array of all investigators for the department' do
        [
          [dept1, pi],
          [dept2, co]
        ].each do |dept, i|
          graph = d3_all_investigators_graph(dept)
          graph.size.should eq 1
          assert_investigator_graph(graph.first, i, nil)
        end
      end
    end
  end

  describe '.d3_investigator_wordle_data' do

    before do
      # setup the data like in rake task setup:wordle
      # cf. lib/tasks/setup.rake
      WordFrequency.save_abstract_frequency_map
      WordFrequency.save_investigator_frequency_map
    end

    it 'gathers words as an Array of Hashes' do
      words = WordFrequency.investigator_wordle_data(pi)
      words = WordFrequency.wordle_distribution(words)
      words = words.flatten
      words.size.should eq 150
      words.each do |w|
        [:word, :frequency, :the_type].each do |key|
          w.should have_key(key)
          case key
          when :word
            p w[key]
          when :frequency
            w[key].should eq 1 # as there is only one Abstract in the setup data
          when :the_type
            w[key].should eq 'Abstract'
          end
        end
      end
    end
  end

  ##
  # Assert that the given Hash (graph) has the appropriate
  # :name, :size, and :imports values for the given OrganzationalUnit
  # @param Hash graph
  # @param OrganizationalUnit ou
  def assert_department_graph(graph, ou)
    graph[:name].should eq ou.name
    graph[:size].should eq OrganizationAbstract.where(organizational_unit_id: ou.id).count
    graph[:imports].should eq ['']
  end

  ##
  # Assert that the given Hash (graph) has the appropriate
  # :name, :size, and :imports values for the given pi (i)
  #
  # :name is the matrix key for the chord diagram
  # :size is the number of publications for the pi
  # :imports is an Array of co-author :name values (either ou_name or co_author.last_name)
  #
  # @param Hash graph
  # @param Investigator i - the investigator in question
  # @param Investigaror i2 - co_author of the Investigator i (setup sets just one co-author)
  # @param department_graph - default false - flag for matrix key
  def assert_investigator_graph(graph, i, i2, department_graph = false)
    name = department_graph ? ou_name(i) : i.last_name
    graph[:name].should eq name
    graph[:size].should eq pi.abstracts.count # probably should be scoped to the org unit
    graph[:imports].should eq imports(department_graph, i2) # co-authorship associations
  end

  ##
  # cf. the name function in /app/views/cytoscape/chord.html.erb
  #   // Returns the Flare package name for the given class name.
  #   // We can make it program name.investigator_username
  # so this is the matrix key for the Organizational Unit chord diagram
  def ou_name(i)
    "#{i.memberships.first.name}.#{i.username}"
  end

  ##
  # department matrix_key cf. ou_name or Investigator.last_name
  def matrix_key(department_graph, i)
    department_graph ? ou_name(i) : i.try(:last_name)
  end

  ##
  # Handles case when i is nil
  # otherwise creates a single element array of the
  # investigator (either the ou_name or the pi last_name)
  # @see matrix_key
  # @return [Array<String>]
  def imports(department_graph, i = nil)
    [matrix_key(department_graph, i)].compact
  end

end
