# -*- coding: utf-8 -*-
require 'spec_helper'

##
# WARNING: This spec runs against the actual LDAP instance.
# You might consider stubbing out the LDAP call, but to
# ensure that the
describe TextUtilities do
  describe '.clean_non_utf_text' do
    context 'given text that includes non-UTF characters' do
      it 'returns that text with those characters altered' do
        txt = "Caf\xc3\xa9"
        TextUtilities.clean_non_utf_text(txt).should eq 'Café'
      end
    end

    context 'given blank text' do
      it 'returns nil' do
        [nil, '', ' '].each do |txt|
          TextUtilities.clean_non_utf_text(txt).should be_nil
        end
      end
    end
  end
end
