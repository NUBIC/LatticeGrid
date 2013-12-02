# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_abstracts
#
#  abstract_id      :integer          not null
#  created_at       :datetime         not null
#  id               :integer          not null, primary key
#  investigator_id  :integer          not null
#  is_first_author  :boolean          default(FALSE), not null
#  is_last_author   :boolean          default(FALSE), not null
#  is_valid         :boolean          default(FALSE), not null
#  last_reviewed_at :datetime
#  last_reviewed_id :integer
#  last_reviewed_ip :string(255)
#  publication_date :date
#  reviewed_at      :datetime
#  reviewed_id      :integer
#  reviewed_ip      :string(255)
#  updated_at       :datetime         not null
#

class InvestigatorAbstract < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :abstract

  has_many :investigator_appointments,
    :through => :investigator,
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]

  validates_uniqueness_of :investigator_id, :scope => "abstract_id"

  scope :first_author_abstracts, where('investigator_abstracts.is_first_author = true and investigator_abstracts.is_valid = true')
  scope :last_author_abstracts, where('investigator_abstracts.is_last_author = true and investigator_abstracts.is_valid = true')
  scope :first_or_last_author_abstracts, where('(investigator_abstracts.is_first_author = true or investigator_abstracts.is_last_author = true) and investigator_abstracts.is_valid = true')
  scope :remove_invalid, where('investigator_abstracts.is_valid = true')
  scope :only_valid, where('investigator_abstracts.is_valid = true')
  scope :only_invalid, where('investigator_abstracts.is_valid = false')
  scope :remove_deleted, where('investigator_abstracts.end_date is null')
  scope :only_deleted, where('investigator_abstracts.end_date is not null')
  scope :by_date_range, lambda { |*args|
    where('investigator_abstracts.publication_date between :start_date and :end_date', { :start_date => args.first, :end_date => args.last })
  }
  scope :for_investigator_ids, lambda { |*ids|
    where('investigator_abstracts.investigator_id IN (:pi_ids) AND investigator_abstracts.is_valid = true', { :pi_ids => ids.first })
  }

  def self.investigator_shared_publication_count_by_date_range(investigator_id, start_date, end_date)
    abs = select('abstract_id')
            .where('investigator_abstracts.investigator_id = :investigator_id and investigator_abstracts.is_valid = true and investigator_abstracts.publication_date between :start_date and :end_date',
              { :investigator_id => investigator_id, :start_date => start_date, :end_date => end_date } ).all
    abstract_ids = abs.map(&:abstract_id)
    # TODO: How is this a hash? The method call is .count?
    the_hash = InvestigatorAbstract.where('investigator_abstracts.abstract_id IN (:ids) AND investigator_abstracts.is_valid = true AND NOT investigator_abstracts.investigator_id = :investigator_id',
      { :ids => abstract_ids, :investigator_id => investigator_id }).group('investigator_id').count
    return nil if the_hash.keys.blank?
    pis = Investigator.where('investigators.id IN (:ids)', { :ids => the_hash.keys }).all
    pis.each do |pi|
      pi["shared_publication_count"] = the_hash[pi.id]
    end
    pis
  end
end
