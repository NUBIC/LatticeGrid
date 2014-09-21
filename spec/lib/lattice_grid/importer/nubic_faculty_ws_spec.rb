# -*- coding: utf-8 -*-

require 'spec_helper'
require 'webmock/rspec'
require_relative 'shared_examples'

describe LatticeGrid::Importer::NubicFacultyWS do
  let(:associations) do
    [
      {:pmid => 123456, :netid => 'wakibbe'},
      {:pmid => 987654, :netid => 'wakibbe'},
      {:pmid => 333333, :netid => 'jstarren'}
    ]
  end

  subject { LatticeGrid::Importer::NubicFacultyWS.new }

  before(:each) do
    LatticeGrid::Importer::NubicFacultyWS.base_url = 'http://facultyws.test'
  end

  it_should_behave_like "a faculty publications api consumer"

  describe '#faculty_publications' do
    let(:body) do
      %q{
          [
            {
                "pmid": 123456,
                "netid": "wakibbe"
            },
            {
                "pmid": 987654,
                "netid": "wakibbe"
            },
            {
                "pmid": 333333,
                "netid": "jstarren"
            }
          ]
        }
    end

    it 'retrieves all faculty publications' do
      stub_request(:get, "http://facultyws.test/faculty_publications").to_return(:body => body, :headers => { 'Content-Type' => 'application/json' })

      subject.faculty_publications.should == associations
    end

    it 'raises an exception when the request is unsuccessful' do
      stub_request(:get, "http://facultyws.test/faculty_publications").to_return(:status => 401)

      expect { subject.faculty_publications }.to raise_error(RuntimeError, "Failed to retreive faculty publications from 'http://facultyws.test/faculty_publications': Status Code 401")
    end

    it 'works when faculty_ws is not at the root path' do
      stub_request(:get, "http://facultyws.test/foo/faculty_publications").to_return(:body => body, :headers => { 'Content-Type' => 'application/json' })
      subject.class.base_url = 'http://facultyws.test/foo'

      subject.faculty_publications.should == associations
    end
  end

  describe '#associate_investigators_with_publications' do
    let(:investigators) do
      [] << Investigator.new(:username => 'wakibbe') << Investigator.new(:username => 'jstarren')
    end

    it 'associates investigators with publications' do
      subject.associate_investigators_with_publications(investigators, associations)
    end
  end

end