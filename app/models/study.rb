# == Schema Information
# Schema version: 20131121210426
#
# Table name: studies
#
#  abstract             :text
#  accrual_goal         :integer
#  approved_date        :date
#  closed_date          :date
#  completed_date       :date
#  created_at           :timestamp
#  created_id           :integer
#  created_ip           :string(255)
#  deleted_at           :timestamp
#  deleted_id           :integer
#  deleted_ip           :string(255)
#  enotis_study_id      :integer
#  exclusion_criteria   :text
#  had_import_errors    :boolean          default(FALSE)
#  has_medical_services :boolean          default(FALSE), not null
#  id                   :integer          not null, primary key
#  inclusion_criteria   :text
#  irb_study_number     :string(255)
#  is_clinical_trial    :boolean          default(FALSE), not null
#  nct_id               :string(255)
#  next_review_date     :date
#  proposal_id          :integer
#  research_type        :string(255)
#  review_type          :string(255)
#  sponsor              :string(255)
#  status               :string(255)
#  title                :text
#  updated_at           :timestamp
#  updated_id           :integer
#  updated_ip           :string(255)
#  url                  :string(255)
#

class Study < ActiveRecord::Base
  has_many :investigator_studies
  has_many :investigators, :through => :investigator_studies

  def pi
    pi_study = self.pi_study
    return nil if pi_study.blank?
    return pi_study.investigator
  end

  def pi_study
    pis = self.investigator_studies.pis
    if pis.length > 0
      return pis.first
    end
    return nil
  end

  def self.without_investigators
    where("not exists(select 'x' from investigator_studies where investigator_studies.study_id = studies.id )").to_a
  end

  def self.without_pi
    where("not exists(select 'x' from investigator_studies where investigator_studies.study_id = studies.id and investigator_studies.role = 'PI' )").to_a
  end

  def self.belonging_to_pi_ids(ids)
    joins([:investigators])
      .where("investigator_studies.role = 'PI' AND investigator_studies.investigator_id in (:ids)", { :ids => ids })
      .order('studies.status, lower(investigators.last_name), lower(investigators.first_name)')
      .to_a
  end

  def self.recents_by_pi(pi_ids, start_date, end_date)
    joins([:investigator_studies])
      .where("investigator_studies.role = 'PI' AND investigator_studies.investigator_id in (:ids) " +
             "and (studies.approved_date < :end_date) and (studies.next_review_date >= :start_date) " +
             "and (studies.closed_date is null or studies.closed_date >= :start_date)",
        {:ids => pi_ids, :start_date=>start_date, :end_date=>end_date })
      .order('studies.approved_date')
      .to_a
   end

end
