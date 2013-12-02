# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: organizational_units
#
#  abbreviation                :string(255)
#  appointment_count           :integer          default(0)
#  campus                      :string(255)
#  children_count              :integer          default(0)
#  created_at                  :datetime         not null
#  department_id               :integer          default(0), not null
#  depth                       :integer          default(0)
#  division_id                 :integer          default(0)
#  end_date                    :date
#  id                          :integer          not null, primary key
#  lft                         :integer
#  member_count                :integer          default(0)
#  name                        :string(255)      not null
#  organization_classification :string(255)
#  organization_phone          :string(255)
#  organization_url            :string(255)
#  parent_id                   :integer
#  rgt                         :integer
#  search_name                 :string(255)
#  sort_order                  :integer          default(1)
#  start_date                  :date
#  type                        :string(255)      not null
#  updated_at                  :datetime         not null
#

require 'spec_helper'

describe OrganizationalUnit do

  it 'can be instantiated' do
    FactoryGirl.build(:organizational_unit).should be_an_instance_of(OrganizationalUnit)
  end

  describe '#head_node' do
    let(:node_name) { 'headnode' }
    before do
      ou = FactoryGirl.create(:program, abbreviation: node_name, department_id: 666, division_id: 999)
      child = FactoryGirl.create(:program, parent_id: ou.id, department_id: 666, division_id: 100)
    end

    it 'finds the desired OrganizationalUnit' do
      OrganizationalUnit.rebuild!
      head_node = OrganizationalUnit.head_node(node_name)
      head_node.should_not be_nil
    end
  end

  context 'with an associated organization_abstract record' do
    let(:organization_abstract) { FactoryGirl.create(:organization_abstract) }
    let(:abstract) { organization_abstract.abstract }
    let(:ou) { organization_abstract.organizational_unit }

    describe 'abstracts association' do
      it 'is not empty' do
        abstract.organization_abstracts.should_not be_empty
        abstract.organizational_units.should_not be_empty
      end
    end

    describe '#abstracts' do
      it 'is not empty' do
        ou.abstracts.should_not be_empty
      end
    end

    describe '#all_abstracts' do
      it 'is not empty' do
        ou.all_abstracts.should_not be_empty
      end
    end

    describe '#all_abstract_ids' do
      it 'is not empty' do
        ou.all_abstract_ids.should_not be_empty
      end
    end

    describe '#abstract_data' do
      it 'returns matching records' do
        abstracts = ou.abstract_data
        abstracts.should_not be_empty
        abstracts.total_entries.should_not be_blank
        abstracts.length.should eq abstracts.total_entries
      end
    end

    describe '#get_minimal_all_data' do
      it 'returns matching records' do
        abstracts = ou.get_minimal_all_data
        abstracts.should_not be_empty
        abstracts.length.should eq ou.abstract_data.length
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end

    describe '#display_year_data' do
      it 'returns nothing for no matching data' do
        abstracts = ou.display_year_data('2000')
        abstracts.should be_empty
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end

      it 'returns matching records' do
        abstracts = ou.display_year_data(abstract.year)
        abstracts.should_not be_empty
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end

    describe '#display_data_by_date' do
      it 'returns matching records' do
        abstracts = ou.display_data_by_date('5/1/2000', '5/1/2525')
        abstracts.should_not be_empty
        abstracts.length.should eq ou.abstract_data.length
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end
  end

  context 'with an associated investigator_appointment record' do
    let(:investigator_appointment) { FactoryGirl.create(:investigator_appointment) }
    let(:ou) { investigator_appointment.organizational_unit }
    let(:investigator) { investigator_appointment.investigator }

    describe '#primary_faculty' do
      before do
        investigator.update_attribute(:home_department_id, ou.id)
      end
      it 'is not empty' do
        ou.primary_faculty.should_not be_empty
      end
    end

    describe '#primary_faculty_publications' do
      before do
        investigator.update_attribute(:home_department_id, ou.id)
        FactoryGirl.create(:investigator_abstract, investigator: investigator, is_valid: true)
      end
      it 'returns the abstracts for the primary_faculty' do
        abstracts = ou.primary_faculty_publications
        abstracts.should_not be_empty
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
        # tree traversal is not working
        # assert(ou.all_faculty.length > 0)
        # abstracts=ou.all_faculty_publications()
        # assert(ou.all_faculty_publications.length == ou.abstract_data.length )
      end
    end

    describe '#members' do
      let(:center) { FactoryGirl.create(:center, division_id: 999) }
      before do
        FactoryGirl.create(:member, investigator: investigator, center: center)
      end
      it 'is not empty' do
        center.members.should_not be_empty
      end
    end

  end

  # TODO: determine how to set up acts_as_nested_set data to get the children
  describe '#acts_as_nested_set' do
    # test "head node" do
    #   OrganizationalUnit.rebuild!
    #   head_node = OrganizationalUnit.head_node("headnode")
    #   assert( head_node.children.length > 0 )
    # end
    #
    # test "test first organizational unit self and descendents not nil" do
    #   OrganizationalUnit.rebuild!
    #   first_unit = organizational_units(:one)
    #   assert( ! first_unit.self_and_descendants.blank?)
    #   assert( first_unit.self_and_descendants.length > 0)
    #   assert( first_unit.self_and_descendants[0].id == first_unit.id)
    # end
  end


end

describe Center do
  it { should belong_to(:school) }
  it { should have_many(:programs) }
end

describe Department do
  it { should belong_to(:school) }
  it { should have_many(:divisions) }
end

describe Division do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:division).should be_persisted
    end
  end
end

describe Program do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:program).should be_persisted
    end
  end
end

describe School do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:school).should be_persisted
    end
  end
end
