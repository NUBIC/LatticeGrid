# -*- coding: utf-8 -*-

shared_examples_for "a faculty publications api consumer" do
  it 'follows the miscellaneous attributes api' do
    should respond_to(:attributes=)
  end

  it 'follows the faculty_publications api' do
    should respond_to(:faculty_publications)
  end
end
